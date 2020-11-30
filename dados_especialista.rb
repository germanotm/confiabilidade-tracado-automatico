##
# Script para extrair dados do Cfaz e criar um csv com os pontos relevantes.
# Usei apenas os pontos usados para calcular fatores e planos, pontos
# de estruturas foram desconsiderados porque não agregam valor científico.
#

traceable_ids = [648585,648519,648522,648697,681974]

ESPECIALISTA = { '648585': "Especialista 1", 
                 '648519': "Especialista 2",
                 '648522': "Especialista 3",
                 '648697': "Especialista 4",
                 '681974': "Automático"
               }

traceables = Teleradiography.where(id: traceable_ids)

data = []
csv = []

traceables.each do |t|
  traceable = { id: t.id, points: [] }

  t.cephalometrics.each do |c|
    
    plan_point_info_ids = c.plan_infos.joins(:point_infos).select("point_infos.id").map(&:id)

    # De fatores
    point_factor_ids = c.factor_sections.joins(:factor_infos => :factor_parameters).
                                       where("factor_parameters.detail_type ='#{PointInfo.to_s}'").
                                       select("detail_id").
                                       map(&:detail_id)
    # PLanos dos fatores
    plan_info_ids = PlanInfo.joins(:factor_parameters => {:factor_info => { :factor_section => :cephalometric } } ).
                             where("cephalometrics.id = #{c.id}").
                             map(&:id)

    point_infos_from_plans_ids = PointInfo.joins(:plan_infos_point_infos => :plan_info).where("plan_infos.id IN (?)",plan_info_ids).map(&:id)


    # Fatores especiais
    special_factors = SpecialFactor.joins(:factor_parameters => {:factor_info => { :factor_section => :cephalometric } } ).
                                    where("cephalometrics.id = #{c.id}")

    special_factor_point_ids = []
    special_factors.each do |special_factor|
      special_factor_point_ids += special_factor.point_info_ids c.user_id
    end

    point_ids = plan_point_info_ids + point_factor_ids + point_infos_from_plans_ids + special_factor_point_ids
    point_ids.uniq!

    points = t.points.where("points.point_info_id in (?)",point_ids)

    points_as_hash = points.map { |p| { number: p.point_info.number,  name: "#{p.point_info.nick} - #{p.point_info.name}", x: p.x, y: p.y , especialist: ESPECIALISTA[t.id.to_s.to_sym] } }
    traceable[:points].push(points_as_hash)
    csv.push(points_as_hash)
  end
  traceable[:points] = traceable[:points].flatten.uniq
  data.push(traceable)
end
csv_data = csv.flatten.uniq

#Cria csv
CSV.open("tmp/dados_especialista.csv", "wb") do |csv|
  csv << csv_data[0].keys
  csv_data.each do |hash|
    csv << hash.values_at(*csv_data[0].keys)
  end
end


# Os pontos necessários em cada uma das análises são:
"McNamara" # 21 pontos
["N - Násio", "Or - Orbital", "Po - Pório", "Ba - Básio", "Co - Condílio", "Go - Gônio", "Me - Mentoniano", "Pog - Pogônio", "Gn - Gnátio", "A - Ponto A", "Ena - Espinha Nasal Anterior", "Ptm - Ptérigo-maxilar", "Vasa - Via Aérea Superior Anterior", "Vasp - Via Aérea Superior Posterior", "Vaia - Via Aérea Inferior Anterior", "Vaip - Via Aérea Inferior Posterior", "Iii - Incisal do Incisivo Inferior", "Sf1/ - Face vestibular do incisivo central superior", "Ls - Lábio Superior", "Sn - Subnasal", "Prn - Pronasal Médio"]
"Ricketts" # 31 pontos
["N - Násio", "Or - Orbital", "Po - Pório", "Ba - Básio", "Dc - Ponto Dc", "Go - Gônio", "Me - Mentoniano", "Pog - Pogônio", "Gn - Gnátio", "Pm - Promentoniano", "A - Ponto A", "Ena - Espinha Nasal Anterior", "Enp - Espinha Nasal Posterior", "Ptm - Ptérigo-maxilar", "Xi - Ponto Xi", "D6/ - Contato Distal do Primeiro Molar Superior", "6/ - Contato Mesial do Primeiro Molar Superior", "Ppd - Ponto Posterior de Downs", "/6 - Contato Mesial do Primeiro Molar Inferior", "PAR - Ponto Anterior de Ricketts", "/3 - Incisal do Canino Inferior", "3/ - Incisal do Canino Superior", "Aii - Ápice Incisivo Inferior", "Iii - Incisal do Incisivo Inferior", "Iis - Incisal do Incisivo Superior", "Ais - Ápice Incisivo Superior", "Pog' - Pogônio do Tecido Mole", "Li - Lábio Inferior", "Stm - Stamion", "Pn - Pronasal", "PTVR - PTVR"]
"USP" # 26 pontos
["N - Násio", "Or - Orbital", "S - Sela", "Po - Pório", "Go - Gônio", "Me - Mentoniano", "Pog - Pogônio", "Gn - Gnátio", "E - Ponto E", "B - Ponto B", "D - Ponto D", "A - Ponto A", "P' - Ponto P Linha", "Ppd - Ponto Posterior de Downs", "Aii - Ápice Incisivo Inferior", "Iii - Incisal do Incisivo Inferior", "Iis - Incisal do Incisivo Superior", "Sf1/ - Face vestibular do incisivo central superior", "Ais - Ápice Incisivo Superior", "Pog' - Pogônio do Tecido Mole", "Ls - Lábio Superior", "Pn - Pronasal", "V - Ponto V", "T - Ponto T", "Tuber - Tuber", "Pi - Protuberância Incisal"]

# fator de conversão de pixel para milimetro nessa imagem
Algebric.pixel_to_millimeter(1,traceables[0].dpi,traceables[0].resize_ratio)
=> 0.22664325925925924

# São 49 pontos únicos necessários para calcular os fatores e planos das 3 análises.