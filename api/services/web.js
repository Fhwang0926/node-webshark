'use strict'

import path from 'path';
import fastify_static from '@fastify/static';
const __dirname = path.resolve();


const main = function (fastify, opts, next) {
  console.log('__dirname', __dirname)
  fastify.register(fastify_static, {
    root: path.join(__dirname, '../web'),
    prefix: '/webshark',
    redirect: true
  })

  next()
}

export default main