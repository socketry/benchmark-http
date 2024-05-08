# Benchmark::HTTP

An asynchronous HTTP benchmark tool built on top of [async](https://github.com/socketry/async), [async-io](https://github.com/socketry/async-io) and [async-http](https://github.com/socketry/async-http). Useful for analysing server performance. Supports HTTP1 and HTTP2.

[![Development Status](https://github.com/socketry/benchmark-http/workflows/Test/badge.svg)](https://github.com/socketry/benchmark-http/actions?workflow=Test)

## Installation

Install it yourself:

    $ gem install benchmark-http

## Usage

You can run `benchmark-http` is a top level tool for invoking specific benchmarks.

### Spider

This benchmark spiders a website and generates some statistics on general access time.

``` shell
$ benchmark-http spider https://www.oriontransfer.co.nz/welcome/index
HEAD https://www.oriontransfer.co.nz/welcome/index -> HTTP/2.0 404 (unspecified bytes)
GET https://www.oriontransfer.co.nz/welcome/index (depth = 10)
GET https://www.oriontransfer.co.nz/welcome/index -> HTTP/2.0 404 (2263 bytes)
HEAD https://www.oriontransfer.co.nz/products/index -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/products/index (depth = 9)
HEAD https://www.oriontransfer.co.nz/services/index -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/services/index (depth = 9)
HEAD https://www.oriontransfer.co.nz/support/index -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/support/index (depth = 9)
HEAD https://www.oriontransfer.co.nz/support/contact-us -> HTTP/2.0 307 (unspecified bytes)
Following redirect to https://www.oriontransfer.co.nz/support/contact-us/index...
HEAD https://www.oriontransfer.co.nz/support/terms-of-service -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/support/terms-of-service (depth = 9)
GET https://www.oriontransfer.co.nz/products/index -> HTTP/2.0 200 (3469 bytes)
GET https://www.oriontransfer.co.nz/services/index -> HTTP/2.0 200 (2488 bytes)
GET https://www.oriontransfer.co.nz/support/index -> HTTP/2.0 200 (2246 bytes)
HEAD https://www.oriontransfer.co.nz/support/contact-us/index -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/support/contact-us/index (depth = 8)
GET https://www.oriontransfer.co.nz/support/terms-of-service -> HTTP/2.0 200 (8466 bytes)
HEAD https://www.oriontransfer.co.nz/products/library-inspector/index -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/products/library-inspector/index (depth = 8)
HEAD https://www.oriontransfer.co.nz/products/truth-tables/index -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/products/truth-tables/index (depth = 8)
HEAD https://www.oriontransfer.co.nz/products/fingerprint/index -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/products/fingerprint/index (depth = 8)
HEAD https://www.oriontransfer.co.nz/services/internet-services -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/services/internet-services (depth = 8)
HEAD https://www.oriontransfer.co.nz/services/software-development -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/services/software-development (depth = 8)
HEAD https://www.oriontransfer.co.nz/services/systems-administration -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/services/systems-administration (depth = 8)
HEAD https://www.oriontransfer.co.nz/services/website-development -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/services/website-development (depth = 8)
HEAD https://www.oriontransfer.co.nz/support/contact-us/ -> HTTP/2.0 307 (unspecified bytes)
Following redirect to https://www.oriontransfer.co.nz/support/contact-us/index...
GET https://www.oriontransfer.co.nz/support/contact-us/index -> HTTP/2.0 200 (3094 bytes)
GET https://www.oriontransfer.co.nz/products/library-inspector/index -> HTTP/2.0 200 (5592 bytes)
GET https://www.oriontransfer.co.nz/products/truth-tables/index -> HTTP/2.0 200 (4160 bytes)
GET https://www.oriontransfer.co.nz/products/fingerprint/index -> HTTP/2.0 200 (4414 bytes)
GET https://www.oriontransfer.co.nz/services/internet-services -> HTTP/2.0 200 (3362 bytes)
GET https://www.oriontransfer.co.nz/services/software-development -> HTTP/2.0 200 (3521 bytes)
GET https://www.oriontransfer.co.nz/services/systems-administration -> HTTP/2.0 200 (2979 bytes)
GET https://www.oriontransfer.co.nz/services/website-development -> HTTP/2.0 200 (3943 bytes)
HEAD https://www.oriontransfer.co.nz/_gallery/products/library-inspector/_screenshots/large/Library%20Inspector%20(Libraries).png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/library-inspector/_screenshots/large/Library%20Inspector%20(Libraries%20Disassembly).png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/library-inspector/_screenshots/large/Library%20Inspector%20(Libraries%20QuickLook).png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/library-inspector/_screenshots/large/Library%20Inspector%20(App).png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/library-inspector/_screenshots/large/Library%20Inspector%20(App%20Headers).png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/truth-tables/_screenshots/large/Reformat%20Expression.png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/truth-tables/_screenshots/large/Large%20Tables.png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/truth-tables/_screenshots/large/Tutor.png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/truth-tables/_screenshots/large/Informative%20Text.png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/fingerprint/_screenshots/large/Fingerprint%20(3).png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/fingerprint/_screenshots/large/Fingerprint%20(2).png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/_gallery/products/fingerprint/_screenshots/large/Fingerprint%20(1).png -> HTTP/2.0 200 (unspecified bytes)
Unsupported content type: image/png
HEAD https://www.oriontransfer.co.nz/services/training -> HTTP/2.0 200 (unspecified bytes)
GET https://www.oriontransfer.co.nz/services/training (depth = 7)
GET https://www.oriontransfer.co.nz/services/training -> HTTP/2.0 200 (2994 bytes)
14 samples: 13x 200; 1x 404. 15.12 requests per second. S/D: 35.69ms.
```

### Concurrency

This benchmark determines the optimal level of concurrency (maximise throughput while keeping latency to a minimum).

``` shell
$ benchmark-http concurrency https://www.oriontransfer.co.nz/welcome/index
I am going to benchmark https://www.oriontransfer.co.nz/welcome/index...
I am running 1 asynchronous tasks that will each make sequential requests...
I made 273 requests in 52.4s. The per-request latency was 191.79ms. That's 5.214149911737622 asynchronous requests/second.
	          Variance: 997.437µs
	Standard Deviation: 31.58ms
	    Standard Error: 0.0019114428646174592
I am running 2 asynchronous tasks that will each make sequential requests...
I made 177 requests in 16.8s. The per-request latency was 190.19ms. That's 10.51600772540387 asynchronous requests/second.
	          Variance: 632.076µs
	Standard Deviation: 25.14ms
	    Standard Error: 0.001889722381767832
I am running 4 asynchronous tasks that will each make sequential requests...
I made 8 requests in 372.49ms. The per-request latency was 186.25ms. That's 21.476841588829895 asynchronous requests/second.
	          Variance: 0.048µs
	Standard Deviation: 219.819µs
	    Standard Error: 7.771792696588776e-05
I am running 8 asynchronous tasks that will each make sequential requests...
I made 128 requests in 3.0s. The per-request latency was 188.10ms. That's 42.53004421587869 asynchronous requests/second.
	          Variance: 399.781µs
	Standard Deviation: 19.99ms
	    Standard Error: 0.0017672840585127617
I am running 16 asynchronous tasks that will each make sequential requests...
I made 184 requests in 2.2s. The per-request latency was 188.46ms. That's 84.89938672881854 asynchronous requests/second.
	          Variance: 548.641µs
	Standard Deviation: 23.42ms
	    Standard Error: 0.0017267724185582615
I am running 32 asynchronous tasks that will each make sequential requests...
I made 152 requests in 891.06ms. The per-request latency was 187.59ms. That's 170.58399627520865 asynchronous requests/second.
	          Variance: 335.694µs
	Standard Deviation: 18.32ms
	    Standard Error: 0.00148610620533633
I am running 64 asynchronous tasks that will each make sequential requests...
I made 438 requests in 1.3s. The per-request latency was 191.68ms. That's 333.89790173541496 asynchronous requests/second.
	          Variance: 1.19ms
	Standard Deviation: 34.51ms
	    Standard Error: 0.001648801656177374
I am running 128 asynchronous tasks that will each make sequential requests...
I made 360 requests in 533.83ms. The per-request latency was 189.81ms. That's 674.373540567776 asynchronous requests/second.
	          Variance: 555.212µs
	Standard Deviation: 23.56ms
	    Standard Error: 0.0012418759009531876
I am running 256 asynchronous tasks that will each make sequential requests...
I made 512 requests in 463.03ms. The per-request latency was 231.51ms. That's 1105.762787139087 asynchronous requests/second.
	          Variance: 888.185µs
	Standard Deviation: 29.80ms
	    Standard Error: 0.0013170938569343825
I am running 192 asynchronous tasks that will each make sequential requests...
I made 384 requests in 380.97ms. The per-request latency was 190.48ms. That's 1007.9615261872923 asynchronous requests/second.
	          Variance: 142.770µs
	Standard Deviation: 11.95ms
	    Standard Error: 0.0006097518459132856
I am running 224 asynchronous tasks that will each make sequential requests...
I made 448 requests in 411.79ms. The per-request latency was 205.89ms. That's 1087.9398101463066 asynchronous requests/second.
	          Variance: 215.480µs
	Standard Deviation: 14.68ms
	    Standard Error: 0.0006935294886115942
I am running 240 asynchronous tasks that will each make sequential requests...
I made 480 requests in 401.62ms. The per-request latency was 200.81ms. That's 1195.1473779597363 asynchronous requests/second.
	          Variance: 292.021µs
	Standard Deviation: 17.09ms
	    Standard Error: 0.0007799848849992035
I am running 248 asynchronous tasks that will each make sequential requests...
I made 496 requests in 432.58ms. The per-request latency was 216.29ms. That's 1146.621534849607 asynchronous requests/second.
	          Variance: 446.681µs
	Standard Deviation: 21.13ms
	    Standard Error: 0.0009489813840514241
I am running 252 asynchronous tasks that will each make sequential requests...
I made 504 requests in 417.86ms. The per-request latency was 208.93ms. That's 1206.1477638702509 asynchronous requests/second.
	          Variance: 222.939µs
	Standard Deviation: 14.93ms
	    Standard Error: 0.0006650854376052381
I am running 254 asynchronous tasks that will each make sequential requests...
I made 508 requests in 419.67ms. The per-request latency was 209.83ms. That's 1210.4835614086478 asynchronous requests/second.
	          Variance: 177.005µs
	Standard Deviation: 13.30ms
	    Standard Error: 0.0005902836562252991
I am running 255 asynchronous tasks that will each make sequential requests...
I made 510 requests in 434.38ms. The per-request latency was 217.19ms. That's 1174.0936493567908 asynchronous requests/second.
	          Variance: 457.592µs
	Standard Deviation: 21.39ms
	    Standard Error: 0.000947227304291054
Your server can handle 255 concurrent requests.
At this level of concurrency, requests have ~1.13x higher latency.
```

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). All contributors to this project must agree to this document to have their contributions accepted.

### Contributor Covenant

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/). All contributors and participants agree to abide by its terms.
