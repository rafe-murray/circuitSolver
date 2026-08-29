Place your .proto files in this directory. Example:

- circuit_graph_message.proto

To generate Dart protobuf bindings (requires protoc and protoc-gen-dart on your PATH):

```
protoc -I=proto --dart_out=grpc:lib/src/generated proto/*.proto
```

After generating, include the generated files in your imports (eg. `lib/src/generated`).
