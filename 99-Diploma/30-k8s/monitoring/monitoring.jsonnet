local ingress(name, namespace, annotations, rules) = {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: name,
    namespace: namespace,
    annotations: annotations,
  },
  spec: { rules: rules },
};

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  (import 'kube-prometheus/addons/networkpolicies-disabled.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      annotations+: {
          withRewrite+: {
            'nginx.ingress.kubernetes.io/use-regex': 'true',
            'nginx.ingress.kubernetes.io/rewrite-target': '/$2',
          },
          noRewrite+: {
            'nginx.ingress.kubernetes.io/use-regex': 'true',
          },
          auth+: {
            'nginx.ingress.kubernetes.io/auth-type': 'basic',
            'nginx.ingress.kubernetes.io/auth-secret': 'basic-auth',
            'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
          },
      }, 
      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: '%(protocol)s://%(domain)s:%(http_port)s/grafana/',
              serve_from_sub_path: "true"
            },
          },
        },
      },
    },
    // Configure External URL's per application
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: 'http://localhost/alertmanager',
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: 'http://localhost/prometheus',
        },
      },
    },
    // Create ingress objects per application
    ingress+:: {
      'alertmanager-main': ingress(
        'alertmanager-main',
        $.values.common.namespace,
        $.values.annotations.withRewrite + $.values.annotations.auth,
        [{
          http: {
            paths: [{
              path: '/alertmanager(/|$)(.*)',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'alertmanager-main',
                  port: {
                    name: 'web',
                  },
                },
              },
            }],
          },
        }]
      ),
      grafana: ingress(
        'grafana',
        $.values.common.namespace,
        $.values.annotations.noRewrite,
        [{
          http: {
            paths: [{
              path: '/grafana(/|$)(.*)',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'grafana',
                  port: {
                    name: 'http',
                  },
                },
              },
            }],
          },
        }],
      ),
      'prometheus-k8s': ingress(
        'prometheus-k8s',
        $.values.common.namespace,
        $.values.annotations.withRewrite + $.values.annotations.auth,
        [{
          http: {
            paths: [{
              path: '/prometheus(/|$)(.*)',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'prometheus-k8s',
                  port: {
                    name: 'web',
                  },
                },
              },
            }],
          },
        }],
      ),
    },
  } + {
    // Create basic auth secret - replace 'auth' file with your own
    ingress+:: {
      'basic-auth-secret': {
        apiVersion: 'v1',
        kind: 'Secret',
        metadata: {
          name: 'basic-auth',
          namespace: $.values.common.namespace,
        },
        data: { auth: std.base64(importstr './auth.htpasswd') },
        type: 'Opaque',
      },
    },
  }; 


{ [name + '-ingress']: kp.ingress[name] for name in std.objectFields(kp.ingress) } +
{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{
  ['setup/' + resource]: kp[component][resource]
  for component in std.objectFields(kp)
  for resource in std.filter(
    function(resource)
      kp[component][resource].kind == 'CustomResourceDefinition' || kp[component][resource].kind == 'Namespace', std.objectFields(kp[component])
  )
} +
{
  [component + '-' + resource]: kp[component][resource]
  for component in std.objectFields(kp)
  for resource in std.filter(
    function(resource)
      kp[component][resource].kind != 'CustomResourceDefinition' && kp[component][resource].kind != 'Namespace', std.objectFields(kp[component])
  )
}
