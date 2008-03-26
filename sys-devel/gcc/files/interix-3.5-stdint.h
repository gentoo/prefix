/*
 * Copyright (c) 2002 Caldera International, Inc. All Rights Reserved.  
 *                                                                       
 *        THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF                 
 *                  Caldera International, Inc.                          
 *                                                                       
 *   The copyright notice above does not evidence any actual or intended 
 *   publication of such source code.                                    
 */

#ifndef _STDINT_H
#define _STDINT_H

#ifndef _SIZE_T_DEFINED
#if defined (lp64) || defined(_WIN64)
typedef unsigned __int64    size_t;
#else
typedef unsigned int  size_t;
#endif
#define _SIZE_T_DEFINED
#define _SIZE_T
#endif/*_SIZE_T_DEFINED*/

#ifndef _SSIZE_T_DEFINED
#if (defined(lp64) || defined(_WIN64))
typedef __int64    ssize_t;
#else
typedef int  ssize_t;
#endif
#define _SSIZE_T_DEFINED
#endif/*_SIZE_T_DEFINED*/


#ifndef _INT8_T
#define _INT8_T
typedef signed char	int8_t;
#endif
#ifndef _INT_LEAST8_T
#define _INT_LEAST8_T
typedef char	int_least8_t;
#endif
#ifndef _INT_FAST8_T
#define _INT_FAST8_T
typedef int	int_fast8_t;
#endif

#ifndef _UINT8_T
#define _UINT8_T
typedef unsigned char	uint8_t;
#endif
#ifndef _UINT_LEAST8_T
#define _UINT_LEAST8_T
typedef unsigned char	uint_least8_t;
#endif
#ifndef _UINT_FAST8_T
#define _UINT_FAST8_T
typedef unsigned int	uint_fast8_t;
#endif

#ifndef _INT16_T
#define _INT16_T
typedef short	int16_t;
#endif
#ifndef _INT_LEAST16_T
#define _INT_LEAST16_T
typedef short	int_least16_t;
#endif
#ifndef _INT_FAST16_T
#define _INT_FAST16_T
typedef int	int_fast16_t;
#endif

#ifndef _UINT16_T
#define _UINT16_T
typedef unsigned short	uint16_t;
#endif
#ifndef _UINT_LEAST16_T
#define _UINT_LEAST16_T
typedef unsigned short	uint_least16_t;
#endif
#ifndef _UINT_FAST16_T
#define _UINT_FAST16_T
typedef unsigned int	uint_fast16_t;
#endif

#ifndef _INT32_T
#define _INT32_T
typedef int	int32_t;
#endif
#ifndef _INT_LEAST32_T
#define _INT_LEAST32_T
typedef int	int_least32_t;
#endif
#ifndef _INT_FAST32_T
#define _INT_FAST32_T
typedef int	int_fast32_t;
#endif

#ifndef _UINT32_T
#define _UINT32_T
typedef unsigned int	uint32_t;
#endif
#ifndef _UINT_LEAST32_T
#define _UINT_LEAST32_T
typedef unsigned int	uint_least32_t;
#endif
#ifndef _UINT_FAST32_T
#define _UINT_FAST32_T
typedef unsigned int	uint_fast32_t;
#endif

#if defined(lp64)

#ifndef _INT64_T
#define _INT64_T
typedef long	int64_t;
#endif
#ifndef _INT_LEAST64_T
#define _INT_LEAST64_T
typedef long	int_least64_t;
#endif
#ifndef _INT_FAST64_T
#define _INT_FAST64_T
typedef long	int_fast64_t;
#endif

#ifndef _UINT64_T
#define _UINT64_T
typedef unsigned long	uint64_t;
#endif
#ifndef _UINT_LEAST64_T
#define _UINT_LEAST64_T
typedef unsigned long	uint_least64_t;
#endif
#ifndef _UINT_FAST64_T
#define _UINT_FAST64_T
typedef unsigned long	uint_fast64_t;
#endif

#else /*!#model(lp64)*/

#ifndef _INT64_T
#define _INT64_T
typedef long long	int64_t;
#endif
#ifndef _INT_LEAST64_T
#define _INT_LEAST64_T
typedef long long	int_least64_t;
#endif
#ifndef _INT_FAST64_T
#define _INT_FAST64_T
typedef long long	int_fast64_t;
#endif

#ifndef _UINT64_T
#define _UINT64_T
typedef unsigned long long	uint64_t;
#endif
#ifndef _UINT_LEAST64_T
#define _UINT_LEAST64_T
typedef unsigned long long	uint_least64_t;
#endif
#ifndef _UINT_FAST64_T
#define _UINT_FAST64_T
typedef unsigned long long	uint_fast64_t;
#endif

#endif /*#model(lp64)*/

#ifndef _INTPTR_T
#define _INTPTR_T
typedef ssize_t intptr_t;
#endif

#ifndef _UINTPTR_T
#define _UINTPTR_T
typedef size_t   uintptr_t;
#endif

#ifndef _INTMAX_T
#define _INTMAX_T
#ifdef __GNUC__
typedef long long int 		  intmax_t;
#else
typedef __int64	intmax_t;
#endif /*__GNUC__*/
#endif

#ifndef _UINTMAX_T
#define _UINTMAX_T
#ifdef __GNUC__
typedef unsigned long long int 	  uintmax_t;
#else
typedef unsigned __int64	uintmax_t;
#endif /*__GNUC__*/
#endif

#if !defined(__cplusplus) || defined(__STDC_LIMIT_MACROS)

#define INT8_MAX	0x7f
#define INT16_MAX	0x7fff
#define INT32_MAX	0x7fffffff
#define INT64_MAX	0x7fffffffffffffff

#define INT8_MIN	(-INT8_MAX - 1)
#define INT16_MIN	(-INT16_MAX - 1)
#define INT32_MIN	(-INT32_MAX - 1)
#define INT64_MIN	(-INT64_MAX - 1)

#define UINT8_MAX	0xff
#define UINT16_MAX	0xffff
#define UINT32_MAX	0xffffffff
#define UINT64_MAX	0xffffffffffffffff

#define INT_LEAST8_MIN	INT8_MIN
#define INT_LEAST16_MIN	INT16_MIN
#define INT_LEAST32_MIN	INT32_MIN
#define INT_LEAST64_MIN	INT64_MIN

#define INT_LEAST8_MAX	INT8_MAX
#define INT_LEAST16_MAX	INT16_MAX
#define INT_LEAST32_MAX	INT32_MAX
#define INT_LEAST64_MAX	INT64_MAX

#define UINT_LEAST8_MAX		UINT8_MAX
#define UINT_LEAST16_MAX	UINT16_MAX
#define UINT_LEAST32_MAX	UINT32_MAX
#define UINT_LEAST64_MAX	UINT64_MAX

#define INT_FAST8_MIN	INT32_MIN
#define INT_FAST16_MIN	INT32_MIN
#define INT_FAST32_MIN	INT32_MIN
#define INT_FAST64_MIN	INT64_MIN

#define INT_FAST8_MAX	INT32_MAX
#define INT_FAST16_MAX	INT32_MAX
#define INT_FAST32_MAX	INT32_MAX
#define INT_FAST64_MAX	INT64_MAX

#define UINT_FAST8_MAX	UINT32_MAX
#define UINT_FAST16_MAX	UINT32_MAX
#define UINT_FAST32_MAX	UINT32_MAX
#define UINT_FAST64_MAX	UINT64_MAX

#if defined(lp64)

#define INTPTR_MIN	INT64_MIN
#define INTPTR_MAX	INT64_MAX
#define UINTPTR_MAX	UINT64_MAX

#define PTRDIFF_MIN	INT64_MIN
#define PTRDIFF_MAX	INT64_MAX

#define SIZE_MAX	INT64_MAX

#else /*!#model(lp64)*/

#define INTPTR_MIN	INT32_MIN
#define INTPTR_MAX	INT32_MAX
#define UINTPTR_MAX	UINT32_MAX

#define PTRDIFF_MIN	INT32_MIN
#define PTRDIFF_MAX	INT32_MAX

#define SIZE_MAX	INT32_MAX

#endif /*#model(lp64)*/

#define INTMAX_MIN	INT64_MIN
#define INTMAX_MAX	INT64_MAX
#define UINTMAX_MAX	UINT64_MAX

#define SIG_ATOMIC_MIN	INT32_MIN
#define SIG_ATOMIC_MAX	INT32_MAX

#define WCHAR_MIN	INT32_MIN
#define WCHAR_MAX	INT32_MAX

#define WINT_MIN	INT32_MIN
#define WINT_MAX	INT32_MAX

#endif /*!defined(__cplusplus) || defined(__STDC_LIMIT_MACROS)*/

#if !defined(__cplusplus) || defined(__STDC_CONSTANT_MACROS)

#define INT8_C(v)	v
#define INT16_C(v)	v
#define INT32_C(v)	v
#define INT64_C(v)	v##LL

#define UINT8_C(v)	v##U
#define UINT16_C(v)	v##U
#define UINT32_C(v)	v##U
#define UINT64_C(v)	v##ULL

#define INTMAX_C(v)	v##LL
#define UINTMAX_C(v)	v##ULL

#endif /*!defined(__cplusplus) || defined(__STDC_CONSTANT_MACROS)*/

#endif /*_STDINT_H*/
