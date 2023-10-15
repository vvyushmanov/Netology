local gitlabK8s = std.native('parseYaml')(importstr 'data://demosite-k8s/demosite-k8s-manifest');

local namespace = {
    metadata+: {
      namespace: "gitlab-agent-demosite-k8s",
    }
};

local gitlabNamespace = {
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
      name: "gitlab-agent-demosite-k8s",
    }
};

local objects = [[ resource + namespace for resource in gitlabK8s ], [ gitlabNamespace ]];

std.flattenArrays(objects)