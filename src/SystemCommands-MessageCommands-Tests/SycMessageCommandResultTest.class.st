Class {
	#name : 'SycMessageCommandResultTest',
	#superclass : 'TestCase',
	#instVars : [
		'classFactory',
		'fixtureClass',
		'browser',
		'context'
	],
	#category : 'SystemCommands-MessageCommands-Tests',
	#package : 'SystemCommands-MessageCommands-Tests'
}

{ #category : 'running' }
SycMessageCommandResultTest >> setUp [
	super setUp.
	classFactory := ClassFactoryForTestCase new.
	fixtureClass := classFactory newClass.
	fixtureClass compile: 'example ^ 1'.
	fixtureClass compile: 'example: value ^ value'.
	browser := SycCommandResultBrowserMock new.
	context := ClySystemBrowserContext for: browser
]

{ #category : 'running' }
SycMessageCommandResultTest >> tearDown [
	classFactory cleanUp.
	super tearDown
]

{ #category : 'tests' }
SycMessageCommandResultTest >> testAddArgumentSelectsResultMethod [
	| command |
	command := SycAddMessageArgumentCommand new
		originalMessage: (SycMessageDescription ofMethod: fixtureClass >> #example);
		newSelector: (RBMethodName selector: #example: arguments: #( 'value' ));
		yourself.
	command applyResultInContext: context.
	self assert: browser selectedMethod equals: fixtureClass >> #example:
]

{ #category : 'tests' }
SycMessageCommandResultTest >> testRemoveArgumentSelectsResultMethod [
	| command |
	command := SycRemoveMessageArgumentCommand new
		originalMessage: (SycMessageDescription ofMethod: fixtureClass >> #example:);
		yourself.
	command methodName selector: #example; arguments: #().
	command applyResultInContext: context.
	self assert: browser selectedMethod equals: fixtureClass >> #example
]

{ #category : 'tests' }
SycMessageCommandResultTest >> testRemoveAllSendersKeepsTargetMethodSelected [
	| command |
	command := SycRemoveAllSendersCommand new
		originalMessage: (SycMessageDescription ofMethod: fixtureClass >> #example);
		yourself.
	command applyResultInContext: context.
	self assert: browser selectedMethod equals: fixtureClass >> #example
]

{ #category : 'tests' }
SycMessageCommandResultTest >> testInlineSendersSelectsOwningClassAfterRemoval [
	| command |
	command := SycInlineIntoLocalSendersMessageCommand new
		originalMessage: (SycMessageDescription ofMethod: fixtureClass >> #example);
		yourself.
	browser selectMethod: fixtureClass >> #example.
	fixtureClass removeSelector: #example.
	command applyResultInContext: context.
	self assert: browser selectedClass equals: fixtureClass.
	self assert: browser selectedMethod isNil
]

{ #category : 'tests' }
SycMessageCommandResultTest >> testInlineSendersSelectsOwningClassFromSourceEditor [
	| command |
	command := SycInlineIntoLocalSendersMessageCommand new
		originalMessage: (SycMessageDescription ofMethod: fixtureClass >> #example);
		yourself.
	fixtureClass removeSelector: #example.
	command applyResultInContext: (ClyMethodSourceCodeContext for: browser).
	self assert: browser selectedClass equals: fixtureClass.
	self assert: browser selectedMethod isNil
]

{ #category : 'tests' }
SycMessageCommandResultTest >> testInlineSendersKeepsSelectionWhenMethodRemains [
	| command selectedMethod |
	command := SycInlineIntoLocalSendersMessageCommand new
		originalMessage: (SycMessageDescription ofMethod: fixtureClass >> #example);
		yourself.
	selectedMethod := fixtureClass >> #example:.
	browser selectMethod: selectedMethod.
	command applyResultInContext: context.
	self assert: browser selectedMethod equals: selectedMethod.
	self assert: (fixtureClass >> #example) sourceCode equals: 'example ^ 1'
]

{ #category : 'tests' }
SycMessageCommandResultTest >> testInlineSendersSelectsOwningClassSideAfterRemoval [
	| command |
	fixtureClass class compile: 'example ^ 1'.
	command := SycInlineIntoLocalSendersMessageCommand new
		originalMessage: (SycMessageDescription ofMethod: fixtureClass class >> #example);
		yourself.
	fixtureClass class removeSelector: #example.
	command applyResultInContext: context.
	self assert: browser selectedClass equals: fixtureClass class.
	self assert: browser selectedMethod isNil
]
