using Requests
using StringEncodings
using Gumbo

function lcs(a, b)
    N = length(a)
    M = length(b)
    MAX = N + M
    V = [0 for _ in 1:2*MAX+1]
    V[MAX + 2] = 0
    Vs = Array{Any, 1}([nothing for _ in 1:2*MAX+1])
    for D in 0:MAX
        for j in -D:2:D
            k = j + MAX + 1
            if (j == -D) | (j != D & V[k-1] < V[k+1])
                x = V[k+1]
                Vloc = Vs[k+1]
            else
                x = V[k-1]+1
                Vloc = Vs[k-1]
            end
            y = x - j
            while (x < N) & (y < M)
                if (a[x+1] == b[y+1])
                    Vloc = ((x+1, y+1), Vloc)
                    x += 1
                    y += 1
                else
                    break
                end
            end
            V[k] = x
            Vs[k] = Vloc
            if (x >= N) & (y >= M)
                lcs = []
                while Vloc != nothing
                    push!(lcs, Vloc[1])
                    Vloc = Vloc[2]
                end
                reverse!(lcs)
                return lcs
            end
        end
    end
end

function undiff(str1, str2, diff)
    newstr = ""
    variat = []
    N = length(str1)
    M = length(str2)
    push!(diff, (N, M))
    xc = 1
    yc = 1
    i = 1
    while (xc < N) | (yc < M)
        if (xc == diff[i][1]) & (yc == diff[i][2])
            newstr *= string(str1[diff[i][1]])
            push!(variat, ("N", xc))
            xc += 1
            yc += 1
            i += 1
        elseif xc < diff[i][1]
            while xc < diff[i][1]
                push!(variat, ("R", xc))
                xc += 1
            end
        elseif yc < diff[i][2]
            while yc < diff[i][2]
                newstr *= string(str2[yc])
                push!(variat, ("I", yc))
                yc += 1
            end
            if yc == M
                newstr *= string(str2[M])
                push!(variat, ("I", M))
                yc += 1
            end
        end
    end
    (newstr, variat)
end

function printdiff(str1, str2, undiff)
    for u in undiff[2]
        if u[1] == "N"
            print(str1[u[2]])
        elseif u[1] == "R"
            # print_with_color(:red, str1[u[2]])
        else
            print_with_color(:yellow, str2[u[2]])
        end
    end
end

function untilde(text)
    pairs = [('á', 'a'), ('é', 'e'), ('í', 'i'), ('ó', 'o'), ('ú', 'u'), ('ñ', 'n')]
    for p in pairs
        text = replace(text, p[1],p[2])
    end
    text
end

function extract_communication(urlsuffix)
    respon = get(baseurl*urlsuffix)
    encded = encode(decode(respon.data, "iso_8859_1"), "utf-8")
    parsd = parsehtml(String(encded))
    ret = String(parsd.root[2][1][3][1][1][1][2][2].text)
    i = 3
    while parsd.root[2][1][3][1][1][1][i].attributes["class"] != "salto-linea"
        ret *= String(parsd.root[2][1][3][1][1][1][i][1].text)
        i += 1
    end
    ret = lowercase(ret)
    ret = untilde(ret)
    ret
end

undiff("asd", "eswq", lcs("asd","eswq"))

baseurl = "http://www.bcra.gov.ar"

previoustit = "PM180327"

latest = "/Noticias/Comunicado_de_Pol%C3%ADtica_Monetaria.asp"
previous = "/PoliticaMonetaria/Comunicado"*previoustit*".asp"

comlast = extract_communication(latest)
comprev = extract_communication(previous)

VCS = lcs(comprev, comlast)
ud = undiff(comprev, comlast, VCS)
printdiff(comprev, comlast, ud)
