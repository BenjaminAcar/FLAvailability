How to use Redis:
```
import redis

r = redis.Redis(
    host='172.18.0.2',
    port=6379, 
    password='a-very-complex-password-here')

print(r)
r.set('foo', 'bar')
value = r.get('foo')
print(value)
```