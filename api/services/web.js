'use strict'

import path from 'path';
import fastify_static from '@fastify/static';

const main = function (fastify, opts, next) {

  const __dirname = path.resolve();

  fastify.register(fastify_static, {
    root: path.join(__dirname.replace('api/', ''), 'web'),
    prefix: '/webshark',
    redirect: true
  })

  next()
}

export default main