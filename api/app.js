'use strict'

import path from 'path';
import AutoLoad from '@fastify/autoload';
const __dirname = path.resolve();

import root from './services/root.js';
import web from './services/web.js';
import upload from './services/upload.js';


// ESM
import Fastify from 'fastify'
const fastify = Fastify({
  logger: true
})

// let main = function (fastify, opts, next) {
//   // fastify.register(AutoLoad, {
//   //   dir: path.join(__dirname, 'services'),
//   //   options: Object.assign({}, opts)
//   // })

//   fastify.register(root);
//   fastify.register(web);
//   fastify.register(upload);

//   // Make sure to call next when done
//   next()
// }


fastify.register(root);
fastify.register(web);
fastify.register(upload);

// const start = async () => {
  try {
    await fastify.listen(8085)
  } catch (err) {
    fastify.log.error(err)
    process.exit(1)
  }
// }
// start()
// export default main