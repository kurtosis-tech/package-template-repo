FROM alpine:latest
CMD ["sh", "-c", "while true; do echo 'Hey\n' && sleep 1; done"]