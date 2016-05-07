# LQNetworkManager
-
A delightful networking library based on AFNetworking 3.0.

### Usage
-

* Get request:

```
[[LQNetworkManager sharedManager] getWithPath:@"https://httpbin.org/" parameters:nil completion:^(id responseObject, NSError *error) {
    }];
```

* Post request:

```
[[LQNetworkManager sharedManager] postWithPath:@"https://httpbin.org/post" parameters:nil completion:^(id responseObject, NSError *error) {
    }];
```

For more details, take a look at the demo project.

