local demositeYaml = std.native('parseYaml')(importstr 'data://demosite/demosite-manifest');

local helmAnnotations = {
   metadata+: {
    annotations+: {
      'meta.helm.sh/release-name': "demosite",
      'meta.helm.sh/release-namespace': "default",
    },
    labels+: {
      "app.kubernetes.io/managed-by": "Helm",
    },
   },
};

[ res + helmAnnotations for res in demositeYaml ]