# protoc-gen-c

Provides a proto build environment for protoc-gen-c.

# Usage

The image runs `protoc` over the `/proto` directory. The generated output is located in `/genproto`

Example:

```sh
docker run -v api:/proto -v genproto:/genproto mfycheng/protoc-gen-c
```

Which compiles all of the protos (recursively) in `./api` and puts it in `./genproto`
