FROM public.ecr.aws/aws-observability/aws-for-fluent-bit:init-debug-2.32.0.20231205

RUN adduser fluent && chown fluent -R /fluent-bit

# コンフィグファイルをコピー
COPY --chown=fluent .container/log_router/web.conf /fluent-bit/etc/extra/web.conf

USER fluent
