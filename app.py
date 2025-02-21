# app.py
from flask import Flask
import redis
import os

app = Flask(__name__)

# Конфігурація Redis
redis_host = os.environ.get('REDIS_HOST') or 'redis' # 'redis' - назва сервісу в docker-compose.yml
redis_port = int(os.environ.get('REDIS_PORT') or 6379)
cache = redis.Redis(host=redis_host, port=redis_port)

@app.route('/')
def hello():
    visits = cache.incr('visits') # Збільшуємо лічильник відвідувань в Redis

    html = f"<h3>Привіт! Кількість відвідувань: {visits}</h3>" \
           f"<b>Ім'я хоста:</b> {os.getenv('HOSTNAME', 'N/A')}<br/>" \
           f"<b>Redis Host:</b> {redis_host}<br/>" \
           f"<b>Redis Port:</b> {redis_port}<br/>"

    return html

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True) # Debug=True для локальної розробки
