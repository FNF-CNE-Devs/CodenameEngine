package funkin.backend.system;

enum abstract ErrorCode(Int) {
	var OK = 0;
	var FAILED = 1;
	var MISSING_PROPERTY = 2;
	var TYPE_INCORRECT = 3;
	var VALUE_NULL = 4;
	var REFLECT_ERROR = 5;
}