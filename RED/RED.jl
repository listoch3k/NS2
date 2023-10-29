# Загружаем параметры модели
include("params.jl")

# Загружаем библиотеки
using DifferentialEquations, Plots

# Индикаторная функция
function I(x)
    if x > 0.0
        return 1.0
    else
        return 0.0
    end
end

# Функция T
function T(x)
    return T_p + x / c
end

# Функция C
function C(x)
    if c < x
        return c
    else
        return x
    end
end

# Функция вычисления вероятности сброса для алгоритма RED
function p_RED(x)
    if (0.0 <= x) && (x < Q_min)
        return 0.0
    elseif x > Q_max
        return 0.0
    else
        p_1 = x - Q_min
        p_2 = Q_max - Q_min
        return p_1 / p_2 * P_max
    end
end

# Вычисление размера окна TCP-Reno
function W_Reno_RED(u)
    return ((I(W_max - u[1])*(1 / T(u[2]))) + I(u[1] - 1)*((-((u[1]) / 2)*(u[1] / T(u[2]))) * p_RED(u[3])))
end

# Вычисление мгновенного размера очереди
function Q_RED(u)
    return -C(u[2])+(I(R - u[2]))*(u[1] / T(u[2]))*(1 - p_RED(u[3])) * N
end

# Вычисление экспоненциально взвешенного скользящего среднего значения мгновенной длины очереди
function Qe(u)
    return ((log(1-wq)/delta)*u[3])-((log(1-wq)/delta)*u[2])
end

# Система уравнений для RED
function RED(du, u, p, t)
    du[1] = W_Reno_RED(u)
    du[2] = Q_RED(u)
    du[3] = Qe(u)
end

# Начальные значения системы и время
u₀ = [1.0, 0.0, 0.0]
tspan = (0.0, stop_time)

# Определение задачи для DifferentialEquations
prob_ode = ODEProblem(RED, u₀, tspan)

# Решение системы уравнений
sol = solve(prob_ode, RK4())

# Строим двухмерный график
plot2d = plot(sol, idxs=(1,2),
lc = "black",
xlabel = "E(w(t))",
ylabel = "E[q(t)]",
legend_font_family = "Computer Modern",
legend = false)

# Сохраняем двухмерный график
savefig(plot2d, "./plots/RED/RED_$(Q_min)_$(Q_max)_2d.pdf")

# Строим трехмерный график
plot3d = plot(sol, idxs=(1,2,3),
lc = "black",
xlabel = "E(w(t))",
ylabel = "E[q(t)]",
zlabel = "E[q̂(t)])",
legend_font_family = "Computer Modern",
legend = false)

# Сохраняем трехмерный график
savefig(plot3d, "./plots/RED/RED_$(Q_min)_$(Q_max)_3d.pdf")

all_f = plot(sol,
lc = "black",
linestyle = [:solid :dash :dot],
xlabel = "t, сек",
ylabel = "пак.",
legend_font_family = "Computer Modern",
xlim = (0,50),
label = ["E(w(t))" "E[q(t)]" "E[q̂(t)]"])

savefig(all_f, "./plots/RED/RED_$(Q_min)_$(Q_max)_all.pdf")