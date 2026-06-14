#!/usr/bin/env bash
# remnawave.sh — установка и управление Remnawave/Remnanode.

_r_remnasetup() {
    need_root || { pause; return; }
    log_info "RemnaSetup (Capybara) — установщик Panel + Node + Caddy."
    bash <(curl -fsSL https://raw.githubusercontent.com/Capybara-z/RemnaSetup/refs/heads/main/install.sh) \
        || log_warn "Установщик завершился с ошибкой."
    log_info "Запуск после установки: remnasetup"
    pause
}

_r_reshala() {
    need_root || { pause; return; }
    log_info "Reshala — TUI-менеджер серверов с интеграцией Remnawave."
    bash <(curl -fsSL https://raw.githubusercontent.com/DonMatteoVPN/Reshala-Remnawave-Bedolaga/main/install.sh) \
        || log_warn "Установщик завершился с ошибкой."
    log_info "Запуск после установки: reshala"
    pause
}

_r_grace() {
    need_root || { pause; return; }
    log_info "Grace Access — worker для выдачи временного доступа EXPIRED/LIMITED."
    if ! has_cmd git; then pkg_install git git; fi
    if ! has_cmd docker; then
        log_warn "Docker не установлен. Установить?"
        prompt "Установить Docker? [y/N]:" ans
        if [[ "$ans" =~ ^[yYдД] ]]; then
            curl -fsSL https://get.docker.com | sh || { log_err "Не удалось установить Docker"; pause; return; }
        else
            pause; return
        fi
    fi
    local dir="/opt/remnawave-grace-access"
    if [[ -d "$dir" ]]; then
        log_info "Каталог $dir уже существует — обновляю."
        git -C "$dir" pull --ff-only || log_warn "git pull не удался."
    else
        git clone https://github.com/zavul0nn/remnawave-grace-access "$dir" \
            || { log_err "Не удалось склонировать репозиторий."; pause; return; }
    fi
    if [[ ! -f "$dir/.env" && -f "$dir/.env.example" ]]; then
        cp "$dir/.env.example" "$dir/.env"
        log_info "Создан $dir/.env — отредактируй его перед запуском."
    fi
    log_info "Готово. Следующие шаги:"
    printf '    cd %s\n    nano .env       # настройки\n    docker compose up -d --build\n' "$dir"
    pause
}

_r_node_logs() {
    if has_cmd docker && docker ps --format '{{.Names}}' | grep -q '^remnanode$'; then
        log_info "Логи remnanode (Ctrl+C для выхода):"
        docker logs --tail 200 -f remnanode
    else
        log_warn "Контейнер remnanode не найден."
        pause
    fi
}

_r_node_restart() {
    if has_cmd docker && docker ps -a --format '{{.Names}}' | grep -q '^remnanode$'; then
        docker restart remnanode && log_ok "remnanode перезапущен."
    else
        log_warn "Контейнер remnanode не найден."
    fi
    pause
}

remnawave_menu() {
    while true; do
        draw_header "Remnawave / Remnanode" "Главная › Remnawave"

        section "Установка"
        menu_item 1 "🎛" "RemnaSetup" "Capybara: Panel + Node + Caddy"
        menu_item 2 "🧰" "Reshala"    "TUI-менеджер"
        menu_item 3 "🆘" "Grace Access" "доступ для EXPIRED/LIMITED"

        section "Управление нодой"
        menu_item 4 "📜" "Логи Remnanode"   "docker logs -f"
        menu_item 5 "🔄" "Рестарт Remnanode" "docker restart"

        draw_line
        menu_item 0 "↩" "Назад" ""
        draw_line

        local ch; prompt "Выбор:" ch
        case "$ch" in
            1) _r_remnasetup ;;
            2) _r_reshala ;;
            3) _r_grace ;;
            4) _r_node_logs ;;
            5) _r_node_restart ;;
            0|q|Q|"") return 0 ;;
            *) log_warn "Нет такого пункта."; sleep 0.8 ;;
        esac
    done
}
