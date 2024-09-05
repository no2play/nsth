import { logger } from 'log';
import { ReadableStream, WritableStream } from 'streams';
import { httpRequest } from 'http-request';
import { createResponse } from 'create-response';
import { TextEncoderStream, TextDecoderStream } from 'text-encode-transform';

const UNSAFE_RESPONSE_HEADERS = ['content-length', 'transfer-encoding', 'connection', 'vary',
  'accept-encoding', 'content-encoding', 'keep-alive',
  'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'upgrade'];

class MinifyStream {
  constructor(fileType) {
    let readController = null;

    this.readable = new ReadableStream({
      start(controller) {
        readController = controller;
      }
    });

    async function handleTemplate(text) {
      // Minify HTML and PHP
      var newtext = minifyCode(text, fileType);
      readController.enqueue(newtext);
    }

    let completeProcessing = Promise.resolve();

    this.writable = new WritableStream({
      write(text) {
        completeProcessing = handleTemplate(text);
      },
      close(controller) {
        completeProcessing.then(() => readController.close());
      }
    });
  }
}

export function responseProvider(request) {
  logger.log('call response provider');
  return httpRequest(`${request.scheme}://${request.host}${request.url}`).then(response => {
    const fileType = getFileType(response.headers.get('content-type'));
    if (fileType === 'html' || fileType === 'php') {
      return createResponse(
        response.status,
        getSafeResponseHeaders(response.getHeaders()),
        response.body.pipeThrough(new TextDecoderStream()).pipeThrough(new MinifyStream(fileType)).pipeThrough(new TextEncoderStream())
      );
    } else {
      // For other file types, return the original response
      return response;
    }
  });
}

function getSafeResponseHeaders(headers) {
  for (let unsafeResponseHeader of UNSAFE_RESPONSE_HEADERS) {
    if (unsafeResponseHeader in headers) {
      delete headers[unsafeResponseHeader]
    }
  }
  return headers;
}

// Minify code function
function minifyCode(text, fileType) {
  let commentPattern, whitespacePattern;

  // Define comment and whitespace patterns based on fileType
  if (fileType === 'html' || fileType === 'php') {
    commentPattern = /<!--[\s\S]*?-->/g;
    whitespacePattern = /\s+/g;
  }

  // Remove comments and collapse whitespace based on fileType
  text = text.replace(commentPattern, '');
  if (whitespacePattern) {
    text = text.replace(whitespacePattern, ' ');
  }

  return text.trim(); // Trim leading and trailing whitespace
}

// Function to determine file type from content type header
function getFileType(contentType) {
  if (contentType.includes('text/html')) {
    return 'html';
  } else if (contentType.includes('text/php')) {
    return 'php';
  }
  // Add more conditions if needed for other file types
  return '';
}
