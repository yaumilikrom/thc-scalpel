#!/usr/bin/env python3

import requests
import json
import time
import argparse
import sys
from typing import List, Dict, Optional
from urllib.parse import urlparse
import ipaddress
from concurrent.futures import ThreadPoolExecutor, as_completed
import csv
from datetime import datetime

class THCRecon:
    
    BASE_URL = "https://ip.thc.org"
    
    def __init__(self, timeout: int = 30, delay: float = 0.5, threads: int = 5):
        
        self.timeout = timeout
        self.delay = delay
        self.threads = threads
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        
    def _make_request(self, endpoint: str) -> Optional[Dict]:
        
        try:
            time.sleep(self.delay)  
            url = f"{self.BASE_URL}/{endpoint}"
            response = self.session.get(url, timeout=self.timeout)
            
            if response.status_code == 200:
               
                return {"success": True, "data": response.text.strip().split('\n')}
            elif response.status_code == 404:
                return {"success": False, "error": "No data found"}
            else:
                return {"success": False, "error": f"HTTP {response.status_code}"}
                
        except requests.exceptions.Timeout:
            return {"success": False, "error": "Timeout"}
        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}
    
    def reverse_dns(self, ip: str) -> Dict:
        
        print(f"[*] rDNS request for {ip}")
        return self._make_request(ip)
    
    def reverse_dns_subnet(self, subnet: str) -> Dict:
       
        print(f"[*] rDNS request for subnet {subnet}")
        return self._make_request(subnet)
    
    def subdomains(self, domain: str) -> Dict:
       
        print(f"[*] Search for subdomains for {domain}")
        return self._make_request(f"sb/{domain}")
    
    def cname_lookup(self, domain: str) -> Dict:
        
        print(f"[*] CNAME search for {domain}")
        return self._make_request(f"cn/{domain}")
    
    def bulk_recon_ips(self, ip_list: List[str]) -> Dict[str, Dict]:
       
        results = {}
        
        with ThreadPoolExecutor(max_workers=self.threads) as executor:
            future_to_ip = {executor.submit(self.reverse_dns, ip): ip for ip in ip_list}
            
            for future in as_completed(future_to_ip):
                ip = future_to_ip[future]
                try:
                    results[ip] = future.result()
                except Exception as e:
                    results[ip] = {"success": False, "error": str(e)}
        
        return results
    
    def bulk_recon_domains(self, domain_list: List[str]) -> Dict[str, Dict]:
        
        results = {}
        
        with ThreadPoolExecutor(max_workers=self.threads) as executor:
            future_to_domain = {executor.submit(self.subdomains, domain): domain for domain in domain_list}
            
            for future in as_completed(future_to_domain):
                domain = future_to_domain[future]
                try:
                    results[domain] = future.result()
                except Exception as e:
                    results[domain] = {"success": False, "error": str(e)}
        
        return results


class ReconAnalyzer:
        
    @staticmethod
    def find_interesting_hosts(data: List[str], keywords: List[str] = None) -> List[str]:
        
        if keywords is None:
            keywords = ['admin', 'dev', 'test', 'staging', 'internal', 'vpn', 
                       'backup', 'old', 'legacy', 'api', 'db', 'sql', 'mail']
        
        interesting = []
        for line in data:
            for keyword in keywords:
                if keyword in line.lower():
                    interesting.append(line)
                    break
        
        return interesting
    
    @staticmethod
    def extract_unique_domains(data: List[str]) -> List[str]:
        
        domains = set()
        for line in data:
            
            parts = line.split()
            if len(parts) >= 2:
                domains.add(parts[1])
        return sorted(list(domains))
    
    @staticmethod
    def group_by_subnet(results: Dict[str, Dict]) -> Dict[str, List]:
        
        subnets = {}
        
        for ip, data in results.items():
            try:
                ip_obj = ipaddress.ip_address(ip)
                subnet = str(ipaddress.ip_network(f"{ip}/24", strict=False))
                
                if subnet not in subnets:
                    subnets[subnet] = []
                
                subnets[subnet].append({
                    'ip': ip,
                    'data': data
                })
            except ValueError:
                continue
        
        return subnets


class ReportGenerator:
        
    @staticmethod
    def save_json(data: Dict, filename: str):
        """Save to JSON"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"[+] The report is saved: {filename}")
    
    @staticmethod
    def save_csv(data: Dict, filename: str):
        
        with open(filename, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['Target', 'Status', 'Results'])
            
            for target, result in data.items():
                status = 'Success' if result.get('success') else 'Failed'
                results = '\n'.join(result.get('data', [])) if result.get('success') else result.get('error', '')
                writer.writerow([target, status, results])
        
        print(f"[+] The report is saved: {filename}")
    
    @staticmethod
    def print_summary(data: Dict):
        
        print("\n" + "="*60)
        print("INTELLIGENCE SUMMARY")
        print("="*60)
        
        total = len(data)
        successful = sum(1 for v in data.values() if v.get('success'))
        failed = total - successful
        
        print(f"Total goals: {total}")
        print(f"Successfully: {successful}")
        print(f"Errors: {failed}")
                
        total_records = 0
        for result in data.values():
            if result.get('success'):
                total_records += len(result.get('data', []))
        
        print(f"Total records found: {total_records}")
        print("="*60 + "\n")


def parse_arguments():
  
    parser = argparse.ArgumentParser(
        description='THC Scalpel Tool - Automation of stealth intelligence for Red Team Crew',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Usage examples:

  # Reverse DNS for a single IP
  python thc-scalpel.py -i 140.82.121.3
  
  # Reverse DNS for a subnet mask
  python thc-scalpel.py -s 140.82.121.0/24
  
  # Search Subdomains
  python thc-scalpel.py -d example.com
  
  # CNAME lookup
  python thc-scalpel.py -c target.com
  
  # Mass intelligence from a file
  python thc-scalpel.py -f targets.txt -t ip
  
  # Saved in the JSON version
  python thc-scalpel.py -d example.com -o report.json -k admin,dev,test
  
  # Stealthy mode with long delay
  python thc-scalpel.py -f domains.txt -t domain --delay 2.0 --threads 3
        """
    )
    
    parser.add_argument('-i', '--ip', help='IP address for reverse DNS')
    parser.add_argument('-s', '--subnet', help='Subnet in CIDR notation')
    parser.add_argument('-d', '--domain', help='Subdomain search domain')
    parser.add_argument('-c', '--cname', help='Domain for CNAME lookup')
    parser.add_argument('-f', '--file', help='A file with a list of goals')
    parser.add_argument('-t', '--type', choices=['ip', 'domain'], 
                       help='The type of targets in the file (ip or domain)')
    
    parser.add_argument('-o', '--output', help='The file for saving the results (JSON/CSV)')
    parser.add_argument('-k', '--keywords', help='Keywords for filtering (separated by commas)')
    parser.add_argument('--format', choices=['json', 'csv'], default='json',
                       help='Output file format (default: json)')
    
    parser.add_argument('--delay', type=float, default=0.5,
                       help='Delay between requests in seconds (default: 0.5)')
    parser.add_argument('--threads', type=int, default=5,
                       help='Number of threads (default: 5)')
    parser.add_argument('--timeout', type=int, default=30,
                       help='Request timeout in seconds (default: 30)')
    
    return parser.parse_args()


def main():
    
    args = parse_arguments()
    
    recon = THCRecon(
        timeout=args.timeout,
        delay=args.delay,
        threads=args.threads
    )
    analyzer = ReconAnalyzer()
    reporter = ReportGenerator()
    
    results = {}
    
    if args.ip:
        results[args.ip] = recon.reverse_dns(args.ip)
    
    elif args.subnet:
        results[args.subnet] = recon.reverse_dns_subnet(args.subnet)
    
    elif args.domain:
        results[args.domain] = recon.subdomains(args.domain)
    
    elif args.cname:
        results[args.cname] = recon.cname_lookup(args.cname)
    
    elif args.file and args.type:
        print(f"[*] Loading targets from {args.file}")
        try:
            with open(args.file, 'r') as f:
                targets = [line.strip() for line in f if line.strip()]
            
            print(f"[*] Targets uploaded: {len(targets)}")
            print(f"[*] Launching exploration in {args.threads} delayed streams {args.delay}s")
            
            if args.type == 'ip':
                results = recon.bulk_recon_ips(targets)
            else:
                results = recon.bulk_recon_domains(targets)
                
        except FileNotFoundError:
            print(f"[!] File not found: {args.file}")
            sys.exit(1)
    
    else:
        print("[!] No target for exploration")
        print("Use --help for reference")
        sys.exit(1)
    
    if not results:
        print("[!] No results available")
        sys.exit(1)
   
    if args.keywords:
        keywords = [k.strip() for k in args.keywords.split(',')]
        print(f"\n[*] Keyword filtering: {', '.join(keywords)}")
        
        filtered_results = {}
        for target, data in results.items():
            if data.get('success'):
                interesting = analyzer.find_interesting_hosts(data['data'], keywords)
                if interesting:
                    filtered_results[target] = {
                        'success': True,
                        'data': interesting
                    }
        
        if filtered_results:
            print(f"[+] Interesting hosts found: {sum(len(v['data']) for v in filtered_results.values())}")
            results = filtered_results
        else:
            print("[!] Nothing was found for the specified keywords.")
       
    reporter.print_summary(results)
    
    if args.output:
        if args.format == 'json':
            reporter.save_json(results, args.output)
        else:
            reporter.save_csv(results, args.output)
   
    print("\n[*] Results (first 50 entries):\n")
    count = 0
    for target, data in results.items():
        print(f"\n[Target: {target}]")
        if data.get('success'):
            for line in data['data'][:50]:
                print(f"  {line}")
                count += 1
                if count >= 50:
                    break
        else:
            print(f"  [!] Error: {data.get('error')}")
        
        if count >= 50:
            print("\n... (rest of the entries are saved to a file)")
            break


if __name__ == "__main__":
    print("""
                                                                           
                                                                          
██████ ██  ██ ▄█████     ▄█████ ▄█████ ▄████▄ ██     █████▄ ██████ ██     
  ██   ██████ ██     ▄▄▄ ▀▀▀▄▄▄ ██     ██▄▄██ ██     ██▄▄█▀ ██▄▄   ██     
  ██   ██  ██ ▀█████     █████▀ ▀█████ ██  ██ ██████ ██     ██▄▄▄▄ ██████ 
                                                                          
  by KL3FT3Z (https://github.com/toxy4ny)
    """)
    
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[!] Interrupted by the user")
        sys.exit(0)
    except Exception as e:
        print(f"\n[!] Critical error: {e}")
        sys.exit(1)