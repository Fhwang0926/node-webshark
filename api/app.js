'use strict'

import path from 'path';
import root from './services/root.js';
import web from './services/web.js';
import upload from './services/upload.js';

// ESM
import Fastify from 'fastify'

module.exports = async function(app, opts) {
  (async () => {
    try {
      const fastify = Fastify({
        logger: true
      })
      
      fastify.register(root);
      fastify.register(web);
      fastify.register(upload);
  
      await fastify.listen({ port: 8085, host: '0.0.0.0' })
    } catch (err) {
      fastify.log.error(err)
      process.exit(1)
    }
  })();
}
