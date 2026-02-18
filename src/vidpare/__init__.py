"""vidpare - A simple video trimmer app."

__version__ = "0.1.0"

def main() -> None:
    """Entry point for the vidpare CLI."""
    print(f"vidpare v{__version__}")
    print("Usage: vidpare <input> <output> --start <time> --end <time>")