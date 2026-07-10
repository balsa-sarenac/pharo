"
This is the baseline for Clap - the Pharo command line handler
"
Class {
	#name : 'BaselineOfClap',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfClap',
	#package : 'BaselineOfClap'
}

{ #category : 'baselines' }
BaselineOfClap >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			package: 'Clap-Core';
			package: 'Clap-Commands-Pharo' with: [ spec requires: #( 'Clap-Core' ) ];
			package: 'Clap-Examples' with: [ spec requires: #( 'Clap-Core' ) ];
			package: 'Clap-UI' with: [ spec requires: #( 'Clap-Core' ) ];
			package: 'Clap-Tests' with: [ spec requires: #( 'Clap-Core' 'Clap-Examples' ) ];
			package: 'Clap-UI-Tests' with: [ spec requires: #( 'Clap-UI' 'Clap-Examples' ) ];
			
			group: 'default' with: #( Core Development );
			group: 'Core' with: #( 'Clap-Core' );
			group: 'Pharo' with: #( 'Clap-Commands-Pharo' );
			group: 'Examples' with: #( 'Clap-Examples' );
			group: 'Tests' with: #( 'Clap-Tests' );
			group: 'Development' with: #( Core Pharo Examples Tests) ;
			group: 'Ui' with: #( 'Clap-UI' 'Clap-UI-Tests' ) ]

]
