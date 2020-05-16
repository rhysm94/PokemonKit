//
//  Queries.swift
//  PokemonKit-iOS
//
//  Created by Rhys Morgan on 16/05/2020.
//  Copyright © 2020 Rhys Morgan. All rights reserved.
//

enum Queries {
	static let getAllPokemon = """
	select
	p.id,
	p.identifier,
	ps.name,
	(select tn.name from type_names as tn
	join pokemon_types as pt on pt.type_id = tn.type_id
	where pt.pokemon_id = p.id and tn.local_language_id = 9 and pt.slot = 1) as typeOne,
	(select tn.name from type_names as tn
	join pokemon_types as pt on pt.type_id = tn.type_id
	where pt.pokemon_id = p.id and tn.local_language_id = 9 and pt.slot = 2) as typeTwo,
	(select pokestat.base_stat from pokemon_stats as pokestat
	where pokestat.pokemon_id = p.id and pokestat.stat_id = 1) as stat_hp,
	(select pokestat.base_stat from pokemon_stats as pokestat
	where pokestat.pokemon_id = p.id and pokestat.stat_id = 2) as stat_atk,
	(select pokestat.base_stat from pokemon_stats as pokestat
	where pokestat.pokemon_id = p.id and pokestat.stat_id = 3) as stat_def,
	(select pokestat.base_stat from pokemon_stats as pokestat
	where pokestat.pokemon_id = p.id and pokestat.stat_id = 4) as stat_spAtk,
	(select pokestat.base_stat from pokemon_stats as pokestat
	where pokestat.pokemon_id = p.id and pokestat.stat_id = 5) as stat_spDef,
	(select pokestat.base_stat from pokemon_stats as pokestat
	where pokestat.pokemon_id = p.id and pokestat.stat_id = 6) as stat_spd,
	(select an.name from ability_names as an
	join pokemon_abilities as pa on
	an.ability_id = pa.ability_id where pa.pokemon_id = p.id
	and an.local_language_id = 9 and pa.slot=1) as ability_one,
	(select an.name from ability_names as an
		join pokemon_abilities as pa
		on an.ability_id = pa.ability_id where pa.pokemon_id = p.id
		and an.local_language_id = 9 and pa.slot=2) as ability_two,
	(select an.name from ability_names as an
	join pokemon_abilities as pa
	on an.ability_id = pa.ability_id where pa.pokemon_id = p.id
	and an.local_language_id = 9 and pa.slot=3) as ability_hidden,
	(select pAlias.identifier from pokemon_species as pAlias
	join pokemon_species as p2
	on p2.evolves_from_species_id = pAlias.id where p2.id = p.id) as evolves_from,
	(select pfn.form_name from pokemon_form_names as pfn
	join pokemon_forms as pf on p.id = pf.pokemon_id
	where pf.id = pfn.pokemon_form_id
	and pfn.local_language_id = 9
	and pf.is_default = 1) as form_name
	from pokemon as p
	join pokemon_species_names as ps on p.id = ps.pokemon_species_id
	where ps.local_language_id = 9;
	"""

	static func getAlternateForms(for dexNum: Int) -> String {
		"""
		select
		p.id,
		p.species_id,
		psn.name,
		(select tn.name from type_names as tn
		join pokemon_types as pt
		on pt.type_id = tn.type_id where pt.pokemon_id = p.id
		and tn.local_language_id = 9 and pt.slot = 1) as typeOne,
		(select tn.name from type_names as tn
		join pokemon_types as pt
		on pt.type_id = tn.type_id where pt.pokemon_id = p.id
		and tn.local_language_id = 9 and pt.slot = 2) as typeTwo,
		(select base_stat from pokemon_stats as stats where stat_id = 1 and stats.pokemon_id = p.id) as hp,
		(select base_stat from pokemon_stats as stats where stat_id = 2 and stats.pokemon_id = p.id) as atk,
		(select base_stat from pokemon_stats as stats where stat_id = 3 and stats.pokemon_id = p.id) as def,
		(select base_stat from pokemon_stats as stats where stat_id = 4 and stats.pokemon_id = p.id) as spAtk,
		(select base_stat from pokemon_stats as stats where stat_id = 5 and stats.pokemon_id = p.id) as spDef,
		(select base_stat from pokemon_stats as stats where stat_id = 6 and stats.pokemon_id = p.id) as spd,
		(select an.name from ability_names as an
		join pokemon_abilities as pa
		on an.ability_id = pa.ability_id where pa.pokemon_id = p.id
		and an.local_language_id = 9 and pa.slot=1) as ability_one,
		(select an.name from ability_names as an
		join pokemon_abilities as pa
		on an.ability_id = pa.ability_id where pa.pokemon_id = p.id
		and an.local_language_id = 9 and pa.slot=2) as ability_two,
		(select an.name from ability_names as an
		join pokemon_abilities as pa
		on an.ability_id = pa.ability_id where pa.pokemon_id = p.id
		and an.local_language_id = 9 and pa.slot=3) as ability_hidden,
		pfn.pokemon_name,
		pfn.form_name,
		pf.identifier,
		pf.form_order,
		pf.is_battle_only,
		pf.is_mega
		from pokemon p
		join pokemon_forms pf on p.id = pf.pokemon_id
		join pokemon_form_names pfn on pf.id = pfn.pokemon_form_id
		join pokemon_species ps on ps.id = p.species_id
		join pokemon_species_names psn on psn.pokemon_species_id = ps.id
		where species_id = \(dexNum)
		and pfn.local_language_id = 9 and psn.local_language_id = 9;
		"""
	}
}
