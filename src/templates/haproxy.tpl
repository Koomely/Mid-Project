global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL). This list is from:
        #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

listen stats
        bind 0.0.0.0:8000
        mode http
        stats enable
        stats uri /haproxy
        stats realm HAProxy

frontend 5050
        bind *:5050
        mode tcp
        default_backend minions

backend minions
mode tcp
balance roundrobin
option httpchk GET / HTTP/1.0
http-check expect status 200
server server1 ${k8s_minion_1}:30036 check port 30036 inter 5s
server server2 ${k8s_minion_2}:30036 check port 30036 inter 5s

frontend consul
        bind *:8050
        mode tcp
        default_backend consul

backend consul
mode tcp
balance roundrobin
option httpchk GET / HTTP/1.0
http-check expect status 301
server server1 ${consul_1}:8500 check port 8500 inter 5s
server server2 ${consul_2}:8500 check port 8500 inter 5s