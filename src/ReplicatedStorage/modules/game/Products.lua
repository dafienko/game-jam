--!strict

export type DevProduct = {
	name: string,
	id: number,
}

export type GamePass = {
	name: string,
	id: number,
	attribute: string,
}

return {
	DevProducts = {
		smallBrickPack = {
			name = "1,000 🧱",
			id = 3370873481,
		} :: DevProduct,
		mediumBrickPack = {
			name = "3,500 🧱",
			id = 3370876399,
		} :: DevProduct,
		largeBrickPack = {
			name = "15,000 🧱",
			id = 3370876754,
		} :: DevProduct,
	},
	GamePasses = {
		tripleRocketLauncher = {
			name = "Triple Rocket Launcher",
			id = 1401814570,
			attribute = "ownsTripleRocketLauncher",
		} :: GamePass,
		doubleBricks = {
			name = "2x Bricks",
			id = 1409880496,
			attribute = "ownsDoubleBricks",
		} :: GamePass,
	},
}
