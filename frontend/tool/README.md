Developer tooling and codegen instructions.

1. Install dependencies

```
flutter pub get
```

2. Generate Drift (sqlite) code

```
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Generate Dart protobufs (requires protoc + protoc-gen-dart)

```
protoc -I=proto --dart_out=grpc:lib/src/generated proto/*.proto
```

4. Run the app on desktop

```
flutter run -d macos
```
