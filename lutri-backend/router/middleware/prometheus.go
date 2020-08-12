package middleware

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type PrometheusHttpMetric struct {
	Prefix                string
	RequestData           *prometheus.CounterVec
	ResponseTimeHistogram *prometheus.SummaryVec
}

func InitPrometheusHttpMetric(prefix string) *PrometheusHttpMetric {
	phm := PrometheusHttpMetric{
		Prefix: prefix,

		RequestData: promauto.NewCounterVec(prometheus.CounterOpts{
			Name: prefix + "_requests",
			Help: "HTTP requests data, grouped by status code, method and handler.",
		}, []string{"code", "method", "handler"},
		),

		ResponseTimeHistogram: promauto.NewSummaryVec(prometheus.SummaryOpts{
			Name: prefix + "_response_time",
			Help: "Histogram of response time for handler.",
		}, []string{"handler", "method"}),
	}

	return &phm
}

func (phm *PrometheusHttpMetric) WrapHandler(handlerLabel string, handlerFunc http.HandlerFunc) http.Handler {
	handle := http.HandlerFunc(handlerFunc)
	wrappedHandler :=
		promhttp.InstrumentHandlerCounter(phm.RequestData.MustCurryWith(prometheus.Labels{"handler": handlerLabel}),
			promhttp.InstrumentHandlerDuration(phm.ResponseTimeHistogram.MustCurryWith(prometheus.Labels{"handler": handlerLabel}),
				handle),
		)
	return wrappedHandler
}
