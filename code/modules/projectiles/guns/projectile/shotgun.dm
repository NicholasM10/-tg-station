/obj/item/weapon/gun/projectile/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = 4
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	var/recentpump = 0 // to prevent spammage

/obj/item/weapon/gun/projectile/shotgun/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		user << "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>"
		A.update_icon()
		update_icon()

/obj/item/weapon/gun/projectile/shotgun/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/shotgun/chamber_round()
	return

/obj/item/weapon/gun/projectile/shotgun/can_shoot()
	if(!chambered)
		return 0
	return (chambered.BB ? 1 : 0)

/obj/item/weapon/gun/projectile/shotgun/attack_self(mob/living/user)
	if(recentpump)
		return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return

/obj/item/weapon/gun/projectile/shotgun/blow_up(mob/user)
	. = 0
	if(chambered && chambered.BB)
		process_fire(user, user,0)
		. = 1

/obj/item/weapon/gun/projectile/shotgun/proc/pump(mob/M)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/proc/pump_unload(mob/M)
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		chambered = null

/obj/item/weapon/gun/projectile/shotgun/proc/pump_reload(mob/M)
	if(!magazine.ammo_count())
		return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC


/obj/item/weapon/gun/projectile/shotgun/examine(mob/user)
	..()
	if (chambered)
		user << "A [chambered.BB ? "live" : "spent"] one is in the chamber."

/obj/item/weapon/gun/projectile/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/weapon/gun/projectile/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."

/obj/item/weapon/gun/projectile/shotgun/riot/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/gun/energy/plasmacutter))
		sawoff(user)
	if(istype(A, /obj/item/weapon/melee/energy))
		var/obj/item/weapon/melee/energy/W = A
		if(W.active)
			sawoff(user)

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/weapon/gun/projectile/shotgun/boltaction
	name = "\improper Mosin Nagant"
	desc = "This piece of junk looks like something that could have been used 700 years ago. It feels slightly moist."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = 0 //no SLOT_BACK sprite, alas
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	var/bolt_open = 0

/obj/item/weapon/gun/projectile/shotgun/boltaction/pump(mob/M)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	if(bolt_open)
		pump_reload(M)
	else
		pump_unload(M)
	bolt_open = !bolt_open
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/boltaction/attackby(obj/item/A, mob/user, params)
	if(!bolt_open)
		user << "<span class='notice'>The bolt is closed!</span>"
		return
	. = ..()

/obj/item/weapon/gun/projectile/shotgun/boltaction/examine(mob/user)
	..()
	user << "The bolt is [bolt_open ? "open" : "closed"]."


/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted

/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted/New()
	..()
	bolt_open = 1
	pump()

/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted/dropped()
	..()
	guns_left = 0

/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted/shoot_live_shot(mob/living/user as mob|obj, pointblank = 0, mob/pbtarget = null, message = 1)
	..()
	if(guns_left)
		var/obj/item/weapon/gun/projectile/shotgun/boltaction/enchanted/GUN = new
		GUN.guns_left = src.guns_left - 1
		user.drop_item()
		user.swap_hand()
		user.put_in_hands(GUN)
	else
		user.drop_item()
	src.throw_at_fast(pick(oview(7,get_turf(user))),1,1)
	user.visible_message("<span class='warning'>[user] tosses aside the spent rifle!</span>")

// Automatic Shotguns//

/obj/item/weapon/gun/projectile/shotgun/automatic/shoot_live_shot(mob/living/user as mob|obj)
	..()
	src.pump(user)

/obj/item/weapon/gun/projectile/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	origin_tech = "combat=6"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = 5

//Dual Feed Shotgun

/obj/item/weapon/gun/projectile/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = 5
	var/toggled = 0
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine

/obj/item/weapon/gun/projectile/shotgun/automatic/dual_tube/New()
	..()
	if (!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/weapon/gun/projectile/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		pump()
	else
		toggle_tube(user)

/obj/item/weapon/gun/projectile/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		user << "You switch to tube B."
	else
		user << "You switch to tube A."

/obj/item/weapon/gun/projectile/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	if(user.incapacitated() || !Adjacent(user) || !istype(user))
		return
	pump()

//Musket

/obj/item/weapon/gun/projectile/shotgun/musket //Not actually a shotgun
	name = "musket"
	desc = "Its piece of wood and a metallic barrel that fires chunks of lead. How do I even shoot it? Surely needs black powder and a rod."
	icon_state = "musket"
	item_state = "musket"
	force = 15
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/musket
	var/hammer_pulled = 0 //if hammer is pulled = 1
	var/powder_loaded = 0

/obj/item/weapon/gun/projectile/shotgun/musket/attack_self(mob/living/user)
	if(!hammer_pulled)
		if(recentpump)
			return
		hammer_pulled = TRUE
		chambered = 1
		playsound(src.loc, 'sound/weapons/shotgunpump.ogg', 30, 1)
		user << "You pull hammer backwards to full-cock position."
		recentpump = 1
		spawn(12)
			recentpump = 0
	else
		if(recentpump)
			return
		hammer_pulled = FALSE
		chambered = null
		playsound(src.loc, 'sound/weapons/shotgunpump.ogg', 30, 1)
		user << "You pull hammer front to half-cock position."
		recentpump = 1
		spawn(12)
			recentpump = 0

/obj/item/weapon/gun/projectile/shotgun/musket/attacked_by(/datum/reagent/blackpowder) //loading black powder
	if(hammer_pulled)
		return //here






// DOUBLE BARRELED SHOTGUN and IMPROVISED SHOTGUN are in revolver.dm
