# =============================================================================
# Dockerfile - web-blog-k8s: App de publicación con almacenamiento persistente
# =============================================================================
FROM python:3.12-alpine
WORKDIR /app
COPY app.py /app/app.py
EXPOSE 8080
CMD ["python", "app.py"]