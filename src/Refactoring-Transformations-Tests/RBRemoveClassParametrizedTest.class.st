Class {
	#name : 'RBRemoveClassParametrizedTest',
	#superclass : 'RBWithDifferentConstructorsParametrizedTest',
	#category : 'Refactoring-Transformations-Tests-Parametrized',
	#package : 'Refactoring-Transformations-Tests',
	#tag : 'Parametrized'
}

{ #category : 'tests' }
RBRemoveClassParametrizedTest class >> testParameters [

	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> ReRemoveClassRefactoring .
					  #constructor -> #classNames: };
		addCase: { #rbClass -> ReRemoveClassesTransformation .
					  #constructor -> #classNames: };
		yourself
]

{ #category : 'running' }
RBRemoveClassParametrizedTest >> setUp [

	super setUp.
	model defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #DecoratorRemovableClass;
			package: #'Refactory-Test data' ]
]

{ #category : 'tests' }
RBRemoveClassParametrizedTest >> testRemoveUnreferencedLeafClass [

	self executeRefactoring: (self createRefactoringWithModel: model andArguments:
			 { { #DecoratorRemovableClass } }).
	self deny: (model includesClassNamed: #DecoratorRemovableClass)
]
