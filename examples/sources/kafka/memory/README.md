# KafkaSource - Memory Evaluation

The following code modification has been done in order to improve the accuracy of memory allocation:
- Go GC is triggered every 3 seconds
- memory metrics is refreshed every 3 seconds

The more partitions, the longer it takes for consumerclaims to start

Overhead (no sources) ~= 6MB.

Scenario 1 : create 1 partitions, send, "as fast as possible", events for 120s, create 1 source and consume for 250s, fetch buffer = 1MB. Collect total heap used every 5s and report

Run 1:
5504 7632 8363 9666 10969 11699 13004 7723 9027 9756 11059 12363 13092 7928 9231 9960 11264 12588 13317 8139 9442 10171 11474 12778 7684 8414 9717 11020 11750 13053 7998 8727 10031 8057 8787 10090 11393 12122 13425 14728 7555 8267 9570 10891 11602 12906 7823 8534 9838 11160 1116

Peak Mb ~= 14

Scenario 2 : create 50 partitions, send, "as fast as possible", events for 120s, create 1 source and consume for 250s, fetch buffer = 1MB

Run 1:
112952 114267 114990 116289 117588 118312 119610 120909 121632 122932 124231 125530 126253 127552 128851 129574 130874 132173 132896 134196 135496 79088 80387 81687 82410 83710 85009 86308 87032 88330 89629 90352 91651 92950 93673 94973 96272 96995 98295 99594 100317 101616 102916 104232 104939 79610 80926 81633 82932 84247 84247

Peak MB ~= 100

Run 2:
7163 59368 119626 108958 110265 110997 112304 113611 114343 115653 116957 117689 118997 120305 121037 122333 123652 124959 125691 126999 128305 129037 130346 131641 132384 133698 78059 78788 80101 81407 82139 83447 84754 86080 86793 88100 89425 90186 91493 92823 93532 94838 96164 96877 98185 99510 100818 101531 102859 104167 104167

Peak MB ~= 130

Scenario 3: create 100 partitions, send, "as fast as possible", events for 120s, create 1 source and consume for 250s, fetch buffer = 1MB

Run 1: Total Heap in kB, collected every 5s
7097 9179 9911 8261 9564 10293 11596 12899 13628 7774 9078 10381 11110 12415 13718 7565 8869 10172 10901 68474 181449 185722 186435 187742 189068 189784 191091 192417 193130 194438 195764 196477 197784 199110 200417 201130 202459 203765 204478 205805 207113 207826 209152 210460 211174 150168 151476 152189 153517 154824 154824

Peak MB ~= 200

Run 2:
6943 8941 7921 9302 10605 11316 7458 8759 85510 153339 154646 155949 156686 157994 159301 160033 161342 162649 163381 164689 165997 107292 108600 109907 110639 111946 113254 114563 115295 116601 117909 118640 119948 121256 121987 123295 124603 125334 126642 127952 128684 129992 131299 132607 133339 107829 109136 109868 111175 112479 112479

Peak MB ~= 165


If a pod does not have enough memory to handle all partitions, some partitions won't be consumed. The adapter shows:

```
{"level":"error","ts":"2021-03-15T15:13:50.957Z","caller":"adapter/adapter.go:116","msg":"Error while consuming messages","error":"kafka: error while consuming topic-100/24: kafka server: The provided member is not known in the current generation.","stacktrace":"knative.dev/eventing-kafka/pkg/source/adapter.(*Adapter).Start.func2\n\tknative.dev/eventing-kafka/pkg/source/adapter/adapter.go:116"}

{"level":"error","ts":"2021-03-15T15:09:44.653Z","caller":"adapter/adapter.go:116","msg":"Error while consuming messages","error":"kafka: error while consuming topic-100/2: read tcp 10.244.0.27:51878->10.244.0.9:9092: i/o timeout","stacktrace":"knative.dev/eventing-kafka/pkg/source/adapter.(*Adapter).Start.func2\n\tknative.dev/eventing-kafka/pkg/source/adapter/adapter.go:116"}
```

After running for several minutes (1000 messages/sec):

```
knative-group-100 topic-100       33         17              13418           13401           -               -               -
knative-group-100 topic-100       66         21              13311           13290           -               -               -
knative-group-100 topic-100       99         13              13365           13352           -               -               -
knative-group-100 topic-100       0          166             13350           13184           -               -               -
```

