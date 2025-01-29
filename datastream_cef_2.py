import json
import logging
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer

# Configure logging
logging.basicConfig(filename='/var/log/datastream_server.log', level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

# Define the port on which the script will listen for requests
PORT = 8444
SIEM_HOST = '172.30.206.66'
SIEM_PORT = 514

# Function to process the received data
def process_data(data):
    try:
        # Parse the JSON data
        data_dict = json.loads(data)

        # Construct the file path with the timestamp from the data
        file_path = f"/var/www/access-logs.nsth-demo.com/logs/datastream_{data_dict['reqTimeSec']}.json"

        # Write the JSON data to a file
        with open(file_path, "w") as f:
            json.dump(data_dict, f)

        # Log a message indicating the file path where data is saved
        logging.info(f"Data saved to: {file_path}")

        # Convert JSON to CEF format and forward to SIEM
        cef_message = json_to_cef(data_dict)
        forward_to_siem(cef_message)
    except json.JSONDecodeError:
        logging.error("Error: Invalid JSON data received!")
    except Exception as e:
        logging.error(f"Error processing data: {e}")

# Function to convert JSON to CEF format
def json_to_cef(data):
    # Map the JSON fields to CEF fields
    cef_fields = {
        'deviceVendor': 'Akamai',
        'deviceProduct': 'DataStream',
        'deviceVersion': '2.0',
        'deviceEventClassId': data.get('reqId', '-'),
        'name': 'DataStream Event',
        'severity': '5',  # You can map severity based on statusCode or other fields
        'src': data.get('cliIP', '-'),
        'dst': data.get('reqHost', '-'),
        'suser': data.get('UA', '-'),
        'requestMethod': data.get('reqMethod', '-'),
        'request': data.get('reqPath', '-'),
        'deviceCustomString1Label': 'ASN',
        'deviceCustomString1': data.get('asn', '-'),
        'deviceCustomString2Label': 'City',
        'deviceCustomString2': data.get('city', '-'),
        'deviceCustomString3Label': 'Country',
        'deviceCustomString3': data.get('country', '-'),
        'deviceCustomNumber1Label': 'Bytes',
        'deviceCustomNumber1': data.get('bytes', '-'),
        'deviceCustomNumber2Label': 'StatusCode',
        'deviceCustomNumber2': data.get('statusCode', '-'),
        'deviceCustomString4Label': 'Referer',
        'deviceCustomString4': data.get('referer', '-'),
        'deviceCustomString5Label': 'UserAgent',
        'deviceCustomString5': data.get('UA', '-'),
        'deviceCustomString6Label': 'RequestTime',
        'deviceCustomString6': data.get('reqTimeSec', '-'),
        'deviceCustomString7Label': 'EdgeAttempts',
        'deviceCustomString7': data.get('edgeAttempts', '-'),
        'deviceCustomString8Label': 'ResponseContentType',
        'deviceCustomString8': data.get('rspContentType', '-'),
        'deviceCustomNumber3Label': 'SSLOverheadTime',
        'deviceCustomNumber3': data.get('tlsOverheadTimeMSec', '-'),
        'deviceCustomString9Label': 'SSLVersion',
        'deviceCustomString9': data.get('tlsVersion', '-'),
        'deviceCustomNumber4Label': 'ObjectSize',
        'deviceCustomNumber4': data.get('objSize', '-'),
        'deviceCustomNumber5Label': 'OverheadBytes',
        'deviceCustomNumber5': data.get('overheadBytes', '-'),
        'deviceCustomNumber6Label': 'TotalBytes',
        'deviceCustomNumber6': data.get('totalBytes', '-'),
        'deviceCustomNumber7Label': 'DNSTime',
        'deviceCustomNumber7': data.get('dnsLookupTimeMSec', '-'),
        'deviceCustomNumber8Label': 'TimeToFirstByte',
        'deviceCustomNumber8': data.get('timeToFirstByte', '-'),
        'deviceCustomNumber9Label': 'DownloadTime',
        'deviceCustomNumber9': data.get('downloadTime', '-'),
        'deviceCustomString10Label': 'CacheStatus',
        'deviceCustomString10': data.get('cacheStatus', '-'),
        'deviceCustomString11Label': 'Cacheable',
        'deviceCustomString11': data.get('cacheable', '-'),
        'deviceCustomString12Label': 'EdgeIP',
        'deviceCustomString12': data.get('edgeIP', '-'),
        'deviceCustomString13Label': 'SecurityRules',
        'deviceCustomString13': data.get('securityRules', '-'),
        'deviceCustomString14Label': 'RequestHost',
        'deviceCustomString14': data.get('reqHost', '-'),
    }

    # Construct the CEF message
    cef_message = f"CEF:0|{cef_fields['deviceVendor']}|{cef_fields['deviceProduct']}|{cef_fields['deviceVersion']}|" \
                  f"{cef_fields['deviceEventClassId']}|{cef_fields['name']}|{cef_fields['severity']}|" \
                  f"src={cef_fields['src']} dst={cef_fields['dst']} suser={cef_fields['suser']} " \
                  f"requestMethod={cef_fields['requestMethod']} request={cef_fields['request']} " \
                  f"cs1Label={cef_fields['deviceCustomString1Label']} cs1={cef_fields['deviceCustomString1']} " \
                  f"cs2Label={cef_fields['deviceCustomString2Label']} cs2={cef_fields['deviceCustomString2']} " \
                  f"cs3Label={cef_fields['deviceCustomString3Label']} cs3={cef_fields['deviceCustomString3']} " \
                  f"cn1Label={cef_fields['deviceCustomNumber1Label']} cn1={cef_fields['deviceCustomNumber1']} " \
                  f"cn2Label={cef_fields['deviceCustomNumber2Label']} cn2={cef_fields['deviceCustomNumber2']} " \
                  f"cs4Label={cef_fields['deviceCustomString4Label']} cs4={cef_fields['deviceCustomString4']} " \
                  f"cs5Label={cef_fields['deviceCustomString5Label']} cs5={cef_fields['deviceCustomString5']} " \
                  f"cs6Label={cef_fields['deviceCustomString6Label']} cs6={cef_fields['deviceCustomString6']} " \
                  f"cs7Label={cef_fields['deviceCustomString7Label']} cs7={cef_fields['deviceCustomString7']} " \
                  f"cs8Label={cef_fields['deviceCustomString8Label']} cs8={cef_fields['deviceCustomString8']} " \
                  f"cn3Label={cef_fields['deviceCustomNumber3Label']} cn3={cef_fields['deviceCustomNumber3']} " \
                  f"cs9Label={cef_fields['deviceCustomString9Label']} cs9={cef_fields['deviceCustomString9']} " \
                  f"cn4Label={cef_fields['deviceCustomNumber4Label']} cn4={cef_fields['deviceCustomNumber4']} " \
                  f"cn5Label={cef_fields['deviceCustomNumber5Label']} cn5={cef_fields['deviceCustomNumber5']} " \
                  f"cn6Label={cef_fields['deviceCustomNumber6Label']} cn6={cef_fields['deviceCustomNumber6']} " \
                  f"cn7Label={cef_fields['deviceCustomNumber7Label']} cn7={cef_fields['deviceCustomNumber7']} " \
                  f"cn8Label={cef_fields['deviceCustomNumber8Label']} cn8={cef_fields['deviceCustomNumber8']} " \
                  f"cn9Label={cef_fields['deviceCustomNumber9Label']} cn9={cef_fields['deviceCustomNumber9']} " \
                  f"cs10Label={cef_fields['deviceCustomString10Label']} cs10={cef_fields['deviceCustomString10']} " \
                  f"cs11Label={cef_fields['deviceCustomString11Label']} cs11={cef_fields['deviceCustomString11']} " \
                  f"cs12Label={cef_fields['deviceCustomString12Label']} cs12={cef_fields['deviceCustomString12']} " \
                  f"cs13Label={cef_fields['deviceCustomString13Label']} cs13={cef_fields['deviceCustomString13']} " \
                  f"cs14Label={cef_fields['deviceCustomString14Label']} cs14={cef_fields['deviceCustomString14']}"

    return cef_message

# Function to forward CEF message to SIEM
def forward_to_siem(cef_message):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(cef_message.encode(), (SIEM_HOST, SIEM_PORT))
        logging.info(f"CEF message forwarded to SIEM: {cef_message}")
    except Exception as e:
        logging.error(f"Error forwarding CEF message to SIEM: {e}")

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
