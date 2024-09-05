import { logger } from 'log';
import { ReadableStream, WritableStream } from 'streams';
import { httpRequest } from 'http-request';
import { createResponse } from 'create-response';
import { TextEncoderStream, TextDecoderStream } from 'text-encode-transform';

// Some headers aren't safe to forward from the origin response through an EdgeWorker on to the client
// For more information see the tech doc on create-response: https://techdocs.akamai.com/edgeworkers/docs/create-response
const UNSAFE_RESPONSE_HEADERS = ['content-length', 'transfer-encoding', 'connection', 'vary',
  'accept-encoding', 'content-encoding', 'keep-alive',
  'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'upgrade'];

class MinifyStream {
  constructor(type) {
    let readController = null;

    this.readable = new ReadableStream({
      start(controller) {
        readController = controller;
      }
    });

    async function handleTemplate(text) {
      let minifiedText;

      if (type === 'js') {
        minifiedText = minifyJavaScript(text);
      } else if (type === 'css') {
        minifiedText = minifyCSS(text);
      }

      readController.enqueue(minifiedText);
    }

    let completeProcessing = Promise.resolve();

    this.writable = new WritableStream({
      write(text) {
        completeProcessing = handleTemplate(text, 0);
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
    let minifyStream;

    // Check if the response is for a JavaScript file
    if (request.url.endsWith('.js')) {
      minifyStream = new MinifyStream('js');
    } else if (request.url.endsWith('.css')) {
      minifyStream = new MinifyStream('css');
    }

    if (minifyStream) {
      return createResponse(
        response.status,
        getSafeResponseHeaders(response.getHeaders()),
        response.body.pipeThrough(new TextDecoderStream()).pipeThrough(minifyStream).pipeThrough(new TextEncoderStream())
      );
    }

    // For other file types, return the response as is
    return response;
  });
}

function removeMultiLineComments(text) {
  return text.replace(/\/\*[\s\S]*?\*\//g, '');
}

function removeWhitespace(text) {
  return text
    .replace(/\s+/g, ' ') // replace multiple spaces with a single space
    .replace(/\s*([,;:{}\[\]\(\)])\s*/g, '$1') // remove spaces around certain characters
    .replace(/^\s*[\r\n]/gm, ''); // remove empty lines
}

function minifyCSS(code) {
  code = removeMultiLineComments(code);
  code = removeWhitespace(code);
  return code;
}

function getSafeResponseHeaders(headers) {
  for (let unsafeResponseHeader of UNSAFE_RESPONSE_HEADERS) {
    if (unsafeResponseHeader in headers) {
      delete headers[unsafeResponseHeader];
    }
  }
  return headers;
}
