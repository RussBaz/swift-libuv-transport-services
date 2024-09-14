# LibUV NIO Transport Services

This is a drop-in replacement for the default Swift NIO event loop, using libUV under the hood (the Node.js event loop library)

## Why?

NIO does not support Windows and it will not do so for a foreseeable future. Therfore, it is better to have unoptimised but working support than none at all.

## Current State

It is pretty much still in a proof of concept state. Basic EventLoop and EventLoopGroup classes are implemented. The next step is to implement task scheduling on libuv owned thread pool (uv_work_t type of libuv requests) After that I would like to add networking and filesystem support.

## Help Needed?

Definitely! Any help will be appreciated in any form. Thanks!
