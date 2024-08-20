import json
import logging
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer

# Configure logging
logging.basicConfig(filename='/var/log/datastream_server.log', level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

# Define the port on which the script will listen for requests
PORT = 8444
SIEM_HOST = '172.30.206.164’
SIEM_PORT = 514

# Function to forward JSON data to SIEM
def forward_to_siem(data):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        # Convert JSON data to bytes and send
        sock.sendto(data.encode(), (SIEM_HOST, SIEM_PORT))
        logging.info(f"Data forwarded to SIEM: {data}")
    except Exception as e:
        logging.error(f"Error forwarding data to SIEM: {e}")

# Function to process the received data
def process_data(data):
    try:
        # Parse the JSON data
        json_data = json.loads(data)

        # Forward the JSON data to SIEM
        forward_to_siem(data)
    except json.JSONDecodeError:
        logging.error("Error: Invalid JSON data received!")
    except Exception as e:
        logging.error(f"Error processing data: {e}")

# Define a class for handling HTTP POST requests
class DataStreamHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            # Read the request body
            content_len = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_len).decode('utf-8')

            # Process the data
            process_data(post_data)

            # Send a successful response
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
        except Exception as e:
            logging.error(f"Error handling POST request: {e}")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b"Internal Server Error")

# Create the server and listen for requests
def run_server():
    server_address = ('', PORT)
    httpd = HTTPServer(server_address, DataStreamHandler)
    logging.info(f"Server listening on port {PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()
        logging.info("Server stopped.")

if __name__ == '__main__':
    run_server()
