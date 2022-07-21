
kubectl apply -k github.com/fluxcd/flagger/kustomize/linkerd |
kubectl -n linkerd rollout status deploy/flagger |
kubectl create ns test | kubectl apply -f https://run.linkerd.io/flagger.yml |
kubectl -n test rollout status deploy podinfo |
Write-Output @" 
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: podinfo
  namespace: test
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: podinfo
  service:
    port: 9898
  analysis:
    interval: 10s
    threshold: 5
    stepWeight: 10
    maxWeight: 100
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99
      interval: 1m
    - name: request-duration
      thresholdRange:
        max: 500
      interval: 1m
"@ > canary.yaml | kubectl apply -f canary.yaml
kubectl -n test set image deployment/podinfo | podinfod=quay.io/stefanprodan/podinfo:1.7.1 |
watch kubectl -n test get canary |
kubectl -n test get trafficsplit podinfo -o yaml |
watch linkerd viz -n test stat deploy --from deploy/load |
kubectl -n test port-forward svc/frontend 8080