import os
import subprocess
import threading
import time
from datetime import datetime
from rich.console import Console
from rich.table import Table
from scapy.all import rdpcap
import shutil

console = Console()
CAPTURE_DIR = "./captures"
os.makedirs(CAPTURE_DIR, exist_ok=True)

stop_capture_flag = threading.Event()


def list_interfaces():
    result = subprocess.run(['tcpdump', '-D'], capture_output=True, text=True)
    interfaces = result.stdout.strip().split('\n')
    interface_map = {}
    console.print("\nAvailable Interfaces:\n")
    for idx, line in enumerate(interfaces, 1):
        console.print(f"[cyan]{idx}[/cyan]. {line}")
        interface_map[str(idx)] = line.split('.')[1].strip().split(' ')[0]
    console.print("[cyan]0[/cyan]. Cancel")
    return interface_map


def capture_packets():
    interface_map = list_interfaces()
    choice = input("\nEnter interface to capture from (0 to cancel): ").strip()
    if choice == '0' or choice not in interface_map:
        return

    iface = interface_map[choice]
    bpf = input("Enter BPF filter (optional, blank to skip): ").strip()
    count = input("How many packets? (blank for unlimited): ").strip()

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"tcpdump_{iface}_{timestamp}.pcap"
    file_path = os.path.join(CAPTURE_DIR, file_name)

    cmd = ["sudo", "tcpdump", "-i", iface, "-w", file_path]
    if bpf:
        cmd += bpf.split()
    if count:
        cmd += ["-c", count]

    def run_capture():
        subprocess.run(cmd)
        console.print("\n[green]Capture finished.[/green]\n")

    thread = threading.Thread(target=run_capture)
    thread.start()

    input("\nPress Enter to stop capture early...\n")
    subprocess.run(["sudo", "pkill", "-f", "tcpdump -i"])
    thread.join()


def analyze_pcap():
    files = sorted([f for f in os.listdir(CAPTURE_DIR) if f.endswith('.pcap')])
    if not files:
        console.print("\n[red]No capture files found.[/red]\n")
        return

    table = Table(title="Capture Files")
    table.add_column("#", justify="right")
    table.add_column("Filename", justify="left")

    for idx, f in enumerate(files, 1):
        table.add_row(str(idx), f)
    table.add_row("0", "Cancel")
    console.print(table)

    choice = input("Select file (0): ").strip()
    if choice == '0' or not choice.isdigit() or int(choice) > len(files):
        return

    file = files[int(choice) - 1]
    path = os.path.join(CAPTURE_DIR, file)
    packets = rdpcap(path)
    console.print(f"Loaded {len(packets)} packets from {path}")

    proto_summary = {}
    for pkt in packets:
        proto = pkt.summary().split()[0]
        proto_summary[proto] = proto_summary.get(proto, 0) + 1

    table = Table(title="Packet Summary")
    table.add_column("Protocol")
    table.add_column("Count", justify="right")
    for proto, count in proto_summary.items():
        table.add_row(proto, str(count))
    console.print(table)


def manage_logs():
    while True:
        console.print("\n[b]Manage TCPDUMP Logs:[/b]")
        console.print("[1] List log files")
        console.print("[2] Delete specific log file(s)")
        console.print("[3] Delete all log files")
        console.print("[4] Export log file")
        console.print("[0] Return to main menu")
        choice = input("Select option: ").strip()

        files = sorted([f for f in os.listdir(CAPTURE_DIR) if f.endswith('.pcap')])

        if choice == '1':
            if not files:
                console.print("No log files found.")
                continue
            table = Table(title="Available Logs")
            table.add_column("#", justify="right")
            table.add_column("Filename", justify="left")
            for idx, f in enumerate(files, 1):
                table.add_row(str(idx), f)
            console.print(table)

        elif choice == '2':
            if not files:
                console.print("No log files to delete.")
                continue
            for idx, f in enumerate(files, 1):
                console.print(f"[{idx}] {f}")
            to_delete = input("Enter number(s) to delete (comma separated): ").split(',')
            for i in to_delete:
                if i.strip().isdigit() and 0 < int(i) <= len(files):
                    os.remove(os.path.join(CAPTURE_DIR, files[int(i.strip()) - 1]))
            console.print("Selected files deleted.")

        elif choice == '3':
            confirm = input("Are you sure you want to delete ALL logs? (y/N): ").lower()
            if confirm == 'y':
                for f in files:
                    os.remove(os.path.join(CAPTURE_DIR, f))
                console.print("All log files deleted.")

        elif choice == '4':
            if not files:
                console.print("No logs to export.")
                continue
            for idx, f in enumerate(files, 1):
                console.print(f"[{idx}] {f}")
            choice = input("Select file to export: ").strip()
            if choice.isdigit() and 0 < int(choice) <= len(files):
                src = os.path.join(CAPTURE_DIR, files[int(choice) - 1])
                dest = input("Enter destination directory: ").strip()
                if os.path.isdir(dest):
                    shutil.copy(src, dest)
                    console.print("File exported successfully.")
                else:
                    console.print("[red]Invalid directory.[/red]")

        elif choice == '0':
            break
        else:
            console.print("Invalid selection.")


def main():
    while True:
        console.print("\n===============================")
        console.print("    [bold]TCPDUMP ADMIN [/bold]    ")
        console.print("===============================")
        console.print("\n[1] List Interfaces")
        console.print("[2] Start Capture")
        console.print("[3] Analyze Saved PCAP")
        console.print("[4] Manage Logs")
        console.print("[5] Exit\n")

        choice = input("Select an option (5): ").strip()

        if choice == '1':
            list_interfaces()
        elif choice == '2':
            capture_packets()
        elif choice == '3':
            analyze_pcap()
        elif choice == '4':
            manage_logs()
        elif choice == '5':
            break
        else:
            console.print("Invalid selection. Please try again.")


if __name__ == "__main__":
    main()
