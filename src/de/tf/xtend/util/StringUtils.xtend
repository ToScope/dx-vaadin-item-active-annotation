package de.tf.xtend.util

class StringUtils {
	/***
	 * Removes each substring of this string that matches the literal 'remove' sequence.
	 */
	def static String remove(String string, String remove) {
		string.replace(remove, "")
	}
}