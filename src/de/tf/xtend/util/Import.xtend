package de.tf.xtend.util

import java.lang.annotation.Repeatable

/***
 * Used, to force the Xtend compiler to add an import
 */
 @Repeatable(Imports)
annotation Import {
	Class<?> value
}