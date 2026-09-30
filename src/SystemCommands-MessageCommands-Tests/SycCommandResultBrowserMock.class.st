Class {
	#name : 'SycCommandResultBrowserMock',
	#superclass : 'Object',
	#instVars : [
		'selectedClass',
		'selectedMethod'
	],
	#category : 'SystemCommands-MessageCommands-Tests',
	#package : 'SystemCommands-MessageCommands-Tests'
}

{ #category : 'accessing' }
SycCommandResultBrowserMock >> browser [
	^ self
]

{ #category : 'navigation' }
SycCommandResultBrowserMock >> selectClass: aClass [
	selectedClass := aClass.
	selectedMethod := nil
]

{ #category : 'navigation' }
SycCommandResultBrowserMock >> selectMethod: aMethod [
	selectedClass := aMethod origin.
	selectedMethod := aMethod
]

{ #category : 'accessing' }
SycCommandResultBrowserMock >> selectedClass [
	^ selectedClass
]

{ #category : 'accessing' }
SycCommandResultBrowserMock >> selectedMethod [
	^ selectedMethod
]
