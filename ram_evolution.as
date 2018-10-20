import flash.events.MouseEvent;

//variables
var totalOrganisms: int = 12; //const
var genesPerOrganism: int = 5; //const
var genotype: Array = new Array();
var totalParentOrganisms: int = 4; //const
var totalChildOrganismsPerParent: int = 3; //const
var generation: int = 0;
var listOfThoseSelected: Array = new Array();
var organismsSelected: int;
var i: int; // two generic counters
var j: int; // too late to remove global variable index, was a bad decision to use it
var randomised: Boolean = false;
var achievementOne: Boolean = false;
var crossoverPopulation: Array = new Array();
//var parentOrganisms:Array = new Array();
//var previouslySelected:Array = new Array();
var allSelections = new Array();
var crossover: Boolean = false;

//listeners
initialise_btn.addEventListener(MouseEvent.MOUSE_UP, initialise);
alertOK.alertButton.addEventListener(MouseEvent.MOUSE_UP, turnOffAlert);
for (i = 1; i <= totalOrganisms; i++) {
	this["select" + i].addEventListener(MouseEvent.MOUSE_UP, selectOrganism);
}
replicate_btn.addEventListener(MouseEvent.MOUSE_UP, replicate);
xover.addEventListener(MouseEvent.MOUSE_UP, changeGenesToCrossover);

//enforcement
alertOK.visible = false;
clearTicks();
this.xover.gotoAndStop(1);
//functions
function changeGenesToCrossover(event: MouseEvent) {
	
	if (this.xover.currentFrame == 1) {
		this.xover.gotoAndStop(2);
		crossover = true;
		trace("Crossover: ");
		trace(crossoverPopulation);

	} else {
		this.xover.gotoAndStop(1);
		crossover = false;
		trace("Genotype: ");
		trace(genotype);
	}
}
function makeMixedGeneticsOffspring(allParents: Array): void {
	// three variants defined by numbers in snapNGenes signature
	var crossoverChildren: Array = new Array();
	var childNum: int = 0;
	var strandOne = new Array();
	var strandTwo = new Array();
	trace("about to create the offspring of " + totalParentOrganisms + " parents");
	var i: int = 0;
	for (i = 0; i < totalParentOrganisms; i++) {
		trace("loop1");
		strandOne = snapNGenes(allParents[i], 0, 2);
		j = i + 1;
		if (j == totalParentOrganisms) {
			j = 0;
		}
		strandTwo = snapNGenes(allParents[j], 2, 3);
		crossoverChildren[childNum] = strandOne.concat(strandTwo);
		childNum++;
		trace(childNum + " children produced.");
	}
	for (i = 0; i < totalParentOrganisms; i++) {
		strandOne = snapNGenes(allParents[i], 0, 3);
		j = i + 1;
		if (j == totalParentOrganisms) {
			j = 0;
		}
		strandTwo = snapNGenes(allParents[j], 3, 2);
		crossoverChildren[childNum] = strandOne.concat(strandTwo);
		childNum++;
		trace(childNum + " children produced.")
	}
	trace(childNum + " children produced.");
	for (i = 0; i < totalParentOrganisms; i++) {
		strandOne = snapNGenes(allParents[i], 0, 1);
		j = i + 1;
		if (j == totalParentOrganisms) {
			j = 0;
		}
		strandTwo = snapNGenes(allParents[j], 1, 4);
		crossoverChildren[childNum] = strandOne.concat(strandTwo);
		childNum++;
		trace(childNum + " children produced.")
	}
	trace("makeMixedGeneticsOffspring result:");
	trace(crossoverChildren);
	trace(genotype);
	trace("end mmgo");
	crossoverPopulation = crossoverChildren;
}

// working with 5 genes, so snap 2 or 3
function snapNGenes(parentStrand: Array, startIndex: int, N: int): Array {
	if (startIndex + N > parentStrand.length) {
		trace("snapNGenes broken again");
		return new Array();
	}
	var outputGenes: Array = new Array();
	var newGuyIndex: int = 0;
	var i: int = 0;
	for (i = startIndex; i < startIndex + N; i++) {
		outputGenes[newGuyIndex] = parentStrand[i];
		newGuyIndex++;
	}
	return outputGenes;
}

function replicate(event: MouseEvent) {
	if (organismsSelected == totalParentOrganisms) {
		produceNewGeneration();
		mutateNewGeneration();
		if (crossover) {
			phenotype(crossoverPopulation);
		}
		else{
			phenotype(genotype);
		}
		this.instruction.dialogue.text = "Generation: " + Number(generation);
	} else {
		alertOK.visible = true;
		alertOK.alertText.text = "Select " + totalParentOrganisms + "parent Organisms.";
	}
	//test section
	// end test section
}
function mutateNewGeneration(): void {
	var newOrgNum: int;
	var mutatedValue: Number;
	for (newOrgNum = 1; newOrgNum < totalOrganisms; newOrgNum++) {
		// 1st gene mutation quantity
		mutatedValue = genotype[newOrgNum][0] + randomIntFromRange(-5, 5);
		// restrict the mutation to its boundaries
		if ((mutatedValue >= 0) && (mutatedValue <= 30)) {
			genotype[newOrgNum][0] = mutatedValue;
		}
		// 2nd gene mutation
		mutatedValue = genotype[newOrgNum][1] + randomIntFromRange(-4, 4);
		if ((mutatedValue >= 25) && (mutatedValue <= 50)) {
			genotype[newOrgNum][1] = mutatedValue;
		}
		// 3rd gene mutation
		mutatedValue = genotype[newOrgNum][2] + randomIntFromRange(-2, 2);
		if ((mutatedValue >= 5) && (mutatedValue <= 15)) {
			genotype[newOrgNum][2] = mutatedValue;
		}
		// 3rd gene mutation
		mutatedValue = genotype[newOrgNum][3] + randomIntFromRange(-6, 6);
		if ((mutatedValue >= 0) && (mutatedValue <= 45)) {
			genotype[newOrgNum][3] = mutatedValue;
		}
		// 4th gene mutation
		mutatedValue = genotype[newOrgNum][4] + randomIntFromRange(-1, 1);
		if ((mutatedValue >= 1) && (mutatedValue <= 3)) {
			genotype[newOrgNum][4] = mutatedValue;
		}
	}
}

function produceNewGeneration(): void {

	generation++;
	var parentGenotype: Array = new Array();
	// copy of all selected
	var parentCounter: int = 0;
	var org: int;
	var parentNum: int;
	var childNum: int;
	var newChildNum: int;
	for (org = 0; org < totalOrganisms; org++) {
		if (listOfThoseSelected[org] == 1) {
			parentGenotype[parentCounter] = genotype[org].slice();
			listOfThoseSelected[org] = 0;
			parentCounter++;
		}
	}
	// create the children
	for (parentNum = 0; parentNum < totalParentOrganisms; parentNum++) {
		for (childNum = 0; childNum < totalChildOrganismsPerParent; childNum++) {
			newChildNum = parentNum * totalChildOrganismsPerParent + childNum;
			genotype[newChildNum] = parentGenotype[parentNum].slice();
		}
	}
	organismsSelected = 0;
	clearSelection();
	refreshTicks();
	allSelections = parentGenotype;
	trace(allSelections);
	makeMixedGeneticsOffspring(parentGenotype);
}

function clearTicks(): void {
	for (i = 1; i <= totalOrganisms; i++) {
		this["tick" + i].visible = false;
	}
}
function clearSelection(): void {
	for (i = 1; i <= totalOrganisms; i++) {
		listOfThoseSelected[i] = 0;
	}
}
function refreshTicks(): void {
	for (i = 1; i <= totalOrganisms; i++) {
		if (listOfThoseSelected[i - 1] == 0) {
			this["tick" + i].visible = false;
		} else if (listOfThoseSelected[i - 1] == 1) {
			this["tick" + i].visible = true;
		}
	}
}
function selectOrganism(event: MouseEvent) {
	if (randomised) {
		var buttonName: String = event.target.name;
		var buttonNumAsString: String = buttonName.replace("select", "");
		var selectedOrganism = Number(buttonNumAsString);
		trace("Organism " + selectedOrganism + " selected");
		this["tick" + selectedOrganism].visible = true;
		if (listOfThoseSelected[selectedOrganism - 1] == 0 || listOfThoseSelected[selectedOrganism - 1] == null) {
			organismsSelected++;
			listOfThoseSelected[selectedOrganism - 1] = 1;
		} else {
			organismsSelected -= 1;
			listOfThoseSelected[selectedOrganism - 1] = 0;
		}
		trace("Selected = " + listOfThoseSelected[selectedOrganism - 1]);
		trace("Num. selected = " + organismsSelected);
		if (organismsSelected > totalParentOrganisms) {
			alertOK.visible = true;
			alertOK.alertText.text = "Too many organisms selected. Please deselect one.";
			// "You have selected more than " + totalParentOrganisms + " organisms. Press OK and 
			// deselect " + (organismsSelected - totalParentOrganisms);
		}
		if (organismsSelected == 4) {
			achievementOne = true;
			this.instruction.dialogue.text = "Now show the survivors' offspring with 'replicate genotype'";
		} else if (achievementOne) {
			this.instruction.dialogue.text = "Select 4 organisms";
			achievementOne = false;
		}
		refreshTicks();
		trace(listOfThoseSelected);
	}
}

function turnOffAlert(event: MouseEvent) {
	alertOK.visible = false;
}

function initialise(event: MouseEvent) {
	randomGenotype();
	phenotype(genotype);
}

function randomGenotype(): void {
	randomised = true;
	this.instruction.dialogue.text = "Now select the 4 rams that will survive the winter";
	clearTicks();

	generation = 0;
	organismsSelected = 0;
	var org: int;
	var genotypeMaker = new Array();

	for (org = 1; org <= totalOrganisms; org++) {
		listOfThoseSelected[org - 1] = 0;
		//gene 1: size of horns
		genotypeMaker[0] = randomIntFromRange(0, 30);
		// this if statement gets rid of floating horns
		if (genotypeMaker[0] < 10) {
			genotypeMaker[0] = 0;
		}
		// gene 2: fatness
		genotypeMaker[1] = randomIntFromRange(25, 50);

		// gene 3: leg width
		genotypeMaker[2] = randomIntFromRange(5, 15);

		// gene 4: ear orientation
		genotypeMaker[3] = randomIntFromRange(0, 45);

		// gene 5: eye size
		genotypeMaker[4] = randomFloatFromRange(1, 3);

		// end function
		genotype[org - 1] = genotypeMaker.slice();
		trace("genotypes of organism " + org + " set");

		// testing section: showing first three genes
		// end of test
	}
	//trace(crossoverPopulation[0]);
}

function phenotype(genotype:Array): void {
	var org: int;
	var propertyOfOrganism: String;
	for (org = 1; org <= totalOrganisms; org++) {
		// gene 1: horns
		propertyOfOrganism = "lhorn" + org;
		this[propertyOfOrganism].height = genotype[org - 1][0];
		this[propertyOfOrganism].width = genotype[org - 1][0];
		trace("left horn " + org + " adjusted.");
		propertyOfOrganism = "rhorn" + org;
		this[propertyOfOrganism].height = genotype[org - 1][0];
		this[propertyOfOrganism].width = genotype[org - 1][0];
		trace("right horn " + org + " adjusted.");
		// gene 2: body
		propertyOfOrganism = "body" + org;
		this[propertyOfOrganism].height = genotype[org - 1][1];
		// gene 3: legs
		propertyOfOrganism = "rfleg" + org;
		this[propertyOfOrganism].width = genotype[org - 1][2];
		propertyOfOrganism = "lfleg" + org;
		this[propertyOfOrganism].width = genotype[org - 1][2];
		propertyOfOrganism = "lbleg" + org;
		this[propertyOfOrganism].width = genotype[org - 1][2];
		propertyOfOrganism = "rbleg" + org;
		this[propertyOfOrganism].width = genotype[org - 1][2];
		// gene 4: tilt the ear
		propertyOfOrganism = "ear" + org;
		this[propertyOfOrganism].rotation = genotype[org - 1][3];
		// gene 4: enlarge the eye
		propertyOfOrganism = "eye" + org;
		this[propertyOfOrganism].width = genotype[org - 1][4];
		this[propertyOfOrganism].height = genotype[org - 1][4];

	}
	//test section
	trace(genotype.length);
	// end of test section
}

function randomIntFromRange(min: int, max: int): int {
	var randomNum: int = Math.floor(Math.random() * (max - min + 1)) + min;
	return randomNum;
}

function randomFloatFromRange(min: int, max: int): Number {
	var randomNum: Number = Math.random() * (max - min + 1) + min;
	return randomNum;
}
