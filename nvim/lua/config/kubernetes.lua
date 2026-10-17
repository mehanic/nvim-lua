return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- Зберігаємо оригінальну функцію name
    local original_name = opts.filesystem and opts.filesystem.components and opts.filesystem.components.name

    opts.filesystem = opts.filesystem or {}
    opts.filesystem.components = opts.filesystem.components or {}

    opts.filesystem.components.name = function(config, node, state)
      local name = node.name or ""
      local path = node.path or ""
      local text = name
      local hl = nil

      -- ========================================================================
      -- 🔹 KUBERNETES: Визначення та підсвітка K8s маніфестів
      -- ========================================================================
      if node.type == "file" and name:match("%.ya?ml$") then
        local is_k8s = false
        local k8s_kind = nil
        local k8s_api = nil

        -- Директорії, що вказують на k8s
        local k8s_dirs = {
          "k8s",
          "kubernetes",
          "manifests",
          "deployments",
          "services",
          "ingress",
          "configmaps",
          "secrets",
          "crds",
          "namespaces",
          "jobs",
          "cronjobs",
          "daemonsets",
          "statefulsets",
          "networkpolicies",
        }
        for _, d in ipairs(k8s_dirs) do
          if path:match("/" .. d) then
            is_k8s = true
            break
          end
        end

        -- Читаємо початок файлу для визначення kind/apiVersion
        if not is_k8s then
          local fd = vim.loop.fs_open(path, "r", 438)
          if fd then
            local stat = vim.loop.fs_fstat(fd)
            if stat and stat.size > 0 then
              local data = vim.loop.fs_read(fd, math.min(stat.size, 2048), 0)
              if data and data:match("apiVersion:") and data:match("kind:") then
                is_k8s = true
                k8s_kind = data:match("kind:%s*(%w+)")
                k8s_api = data:match("apiVersion:%s*([%w%./-]+)")
              end
            end
            vim.loop.fs_close(fd)
          end
        end

        if is_k8s then
          -- Дефолтна іконка для більшості ресурсів
          text = "󱃾 " .. name

          -- Основні ресурси
          if
            k8s_kind == "Deployment"
            or k8s_kind == "StatefulSet"
            or k8s_kind == "DaemonSet"
            or k8s_kind == "Job"
            or k8s_kind == "CronJob"
          then
            hl = "NeoTreeK8sDeployment"
          elseif k8s_kind == "Pod" then
            hl = "NeoTreeK8sPod"
          elseif
            k8s_kind == "Role"
            or k8s_kind == "ClusterRole"
            or k8s_kind == "RoleBinding"
            or k8s_kind == "ClusterRoleBinding"
          then
            text = "󰚁 " .. name
            hl = "NeoTreeK8sRole"
          elseif k8s_kind == "Secret" then
            hl = "NeoTreeK8sSecret"
          elseif k8s_kind == "Ingress" then
            hl = "NeoTreeK8sIngress"
          elseif k8s_kind == "ConfigMap" then
            hl = "NeoTreeK8sConfigMap"
          elseif k8s_kind == "PersistentVolume" then
            hl = "NeoTreeK8sPV"
          elseif k8s_kind == "PersistentVolumeClaim" then
            hl = "NeoTreeK8sPVC"
          elseif k8s_kind == "Namespace" then
            hl = "NeoTreeK8sNamespace"
          elseif k8s_kind == "NetworkPolicy" then
            text = "󰛨 " .. name
            hl = "NeoTreeK8sNetPolicy"
          elseif k8s_kind == "CiliumNetworkPolicy" or k8s_kind == "CiliumClusterwideNetworkPolicy" then
            text = " " .. name
            hl = "NeoTreeK8sNetPolicy"
          elseif k8s_kind == "CustomResourceDefinition" or k8s_kind == "CRD" then
            if k8s_api and k8s_api:match("%.") then
              if k8s_api:match("kyverno") then
                text = "󰓄 " .. name
                hl = "NeoTreeK8sKyverno"
              elseif k8s_api:match("cilium") then
                text = " " .. name
                hl = "NeoTreeK8sNetPolicy"
              elseif k8s_api:match("argo") or k8s_api:match("argocd") then
                text = "󱃾 " .. name
                hl = "NeoTreeK8sArgo"
              elseif k8s_api:match("prometheus") then
                text = "󱃾 " .. name
                hl = "NeoTreeK8sPrometheus"
              elseif k8s_api:match("cert-manager") then
                text = "󱃾 " .. name
                hl = "NeoTreeK8sCertManager"
              elseif k8s_api:match("istio") then
                text = " " .. name
                hl = "NeoTreeK8sIstio"
              elseif k8s_api:match("velero") then
                text = "󱃾 " .. name
                hl = "NeoTreeK8sVelero"
              elseif k8s_api:match("knative") then
                text = "󱃾 " .. name
                hl = "NeoTreeK8sKnative"
              elseif k8s_api:match("opa") then
                text = "󱃾 " .. name
                hl = "NeoTreeK8sOPA"
              elseif k8s_api:match("elastic") then
                text = "󱃾 " .. name
                hl = "NeoTreeK8sElastic"
              elseif k8s_api:match("rabbitmq") then
                text = " " .. name
                hl = "NeoTreeK8sRabbitMQ"
              elseif k8s_api:match("strimzi") then
                text = "󱃾 " .. name
                hl = "NeoTreeK8sKafka"
              else
                text = "󰚀 " .. name
                hl = "NeoTreeK8sCRD"
              end
            else
              text = "󰚀 " .. name
              hl = "NeoTreeK8sCRD"
            end
          else
            hl = "NeoTreeK8s"
          end
        end
      end

      -- Повертаємо результат або делегуємо оригінальній функції
      if hl then
        return { text = text, highlight = hl }
      elseif original_name then
        return original_name(config, node, state)
      end
      return { text = text, highlight = hl }
    end
  end,

  -- ========================================================================
  --  K8s Highlight групи
  -- ========================================================================
  config = function()
    local highlights = {
      NeoTreeK8s = { fg = "#2196f3", bold = true },
      NeoTreeK8sDeployment = { fg = "#4caf50", bold = true },
      NeoTreeK8sPod = { fg = "#2196f3", bold = true },
      NeoTreeK8sRole = { fg = "#9c27b0", bold = true },
      NeoTreeK8sSecret = { fg = "#f44336", bold = true },
      NeoTreeK8sIngress = { fg = "#ff9800", bold = true },
      NeoTreeK8sConfigMap = { fg = "#8bc34a", bold = true },
      NeoTreeK8sPV = { fg = "#00bcd4", bold = true },
      NeoTreeK8sPVC = { fg = "#00bcd4", bold = true },
      NeoTreeK8sNamespace = { fg = "#00bcd4", bold = true },
      NeoTreeK8sNetPolicy = { fg = "#00bfa5", bold = true },
      NeoTreeK8sCRD = { fg = "#e91e63", bold = true },
      NeoTreeK8sKyverno = { fg = "#7e57c2", bold = true },
      NeoTreeK8sCilium = { fg = "#00bcd4", bold = true },
      NeoTreeK8sArgo = { fg = "#ff9800", bold = true },
      NeoTreeK8sPrometheus = { fg = "#4caf50", bold = true },
      NeoTreeK8sCertManager = { fg = "#ffeb3b", bold = true },
      NeoTreeK8sIstio = { fg = "#00bcd4", bold = true },
      NeoTreeK8sVelero = { fg = "#1565c0", bold = true },
      NeoTreeK8sKnative = { fg = "#ff7043", bold = true },
      NeoTreeK8sOPA = { fg = "#6a1b9a", bold = true },
      NeoTreeK8sElastic = { fg = "#d32f2f", bold = true },
      NeoTreeK8sRabbitMQ = { fg = "#e91e63", bold = true },
      NeoTreeK8sKafka = { fg = "#9c27b0", bold = true },
    }

    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end,
}
