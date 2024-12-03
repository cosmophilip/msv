set_iptables_rules() {

    echo "Очистка всех существующих правил OUTPUT"
    iptables -F OUTPUT

    echo "Очистка всех существующих правил INPUT"
    iptables -F INPUT

    echo "Разрешение исходящего трафика в диапазоне Docker от 172.17.0.0/16 до 172.40.0.0/16"
    for i in $(seq 17 40); do
        iptables -A OUTPUT -d 172.$i.0.0/16 -j ACCEPT
    done
    sleep 1

    echo "Добавление блокирующих правил"
    iptables -A OUTPUT -d 10.0.0.0/8 -j DROP
    iptables -A OUTPUT -d 100.64.0.0/10 -j DROP
    iptables -A OUTPUT -d 169.254.0.0/16 -j DROP
    iptables -A OUTPUT -d 172.16.0.0/12 -j DROP
    iptables -A OUTPUT -d 192.0.0.0/24 -j DROP
    iptables -A OUTPUT -d 192.0.2.0/24 -j DROP
    iptables -A OUTPUT -d 192.88.99.0/24 -j DROP
    iptables -A OUTPUT -d 192.168.196.0/24 -j ACCEPT
    iptables -A OUTPUT -d 192.168.0.0/16 -j DROP
    iptables -A OUTPUT -d 198.18.0.0/15 -j DROP
    iptables -A OUTPUT -d 198.51.100.0/24 -j DROP
    iptables -A OUTPUT -d 203.0.113.0/24 -j DROP
    iptables -A OUTPUT -d 224.0.0.0/4 -j DROP
    iptables -A OUTPUT -d 240.0.0.0/4 -j DROP

    echo "Включение IP форвардинга"
    sudo sysctl -w net.ipv4.ip_forward=1

    echo "Настройка правил для форвардинга трафика"
    iptables -A FORWARD -i ztukuxnbla -o ens3 -j ACCEPT
    iptables -A FORWARD -i ens3 -o ztukuxnbla -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE

    echo "Закрытие внешнего доступа к SSH на ens3"
    iptables -A INPUT -i ens3 -p tcp --dport 22 -j DROP

    echo "Разрешение SSH через ztukuxnbla"
    iptables -A INPUT -i ztukuxnbla -s 192.168.196.0/24 -p tcp --dport 22 -j ACCEPT

    sudo iptables-save

    echo "Блокирующие правила успешно применены!"
}
