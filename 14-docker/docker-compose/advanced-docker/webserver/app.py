import os

CONFIG_FILE = "/app/config/config.txt"

def read_config():
    if not os.path.exists(CONFIG_FILE):
        return "Config file not found."
    with open(CONFIG_FILE) as f:
        return f.read()

if __name__ == "__main__":
    from http.server import BaseHTTPRequestHandler, HTTPServer

    PORT = int(os.getenv("PORT", 8000))
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(read_config().encode())

    print(f"Server running on port {PORT}")
    HTTPServer(('', PORT), Handler).serve_forever()