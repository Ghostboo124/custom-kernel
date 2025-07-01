#pragma once

#include <types.h>

/** \defgroup ALLOCHOOKS liballoc hooks 
 *
 * These are the OS specific functions which need to 
 * be implemented on any platform that the library
 * is expected to work on.
 */

/** @{ */

//This lets you prefix malloc and friends
#define PREFIX(func)		k ## func

#ifdef __cplusplus
extern "C" {
#endif



/** This function is supposed to lock the memory data structures. It
 * could be as simple as disabling interrupts or acquiring a spinlock.
 * It's up to you to decide. 
 *
 * \return 0 if the lock was acquired successfully. Anything else is
 * failure.
 */
extern int alloc_lock();

/** This function unlocks what was previously locked by the alloc_lock
 * function.  If it disabled interrupts, it enables interrupts. If it
 * had acquiried a spinlock, it releases the spinlock. etc.
 *
 * \return 0 if the lock was successfully released.
 */
extern int alloc_unlock();

/** This is the hook into the local system which allocates pages. It
 * accepts an integer parameter which is the number of pages
 * required.  The page size was set up in the liballoc_init function.
 *
 * \return NULL if the pages were not allocated.
 * \return A pointer to the allocated memory.
 */
extern void* alloc(size_t);

/** This frees previously allocated memory. The void* parameter passed
 * to the function is the exact same value returned from a previous
 * alloc call.
 *
 * The integer value is the number of pages to free.
 *
 * \return 0 if the memory was successfully freed.
 */
extern int free(void*,size_t);


       

extern void    *PREFIX(malloc)(size_t);				///< The standard function.
extern void    *PREFIX(realloc)(void *, size_t);		///< The standard function.
extern void    *PREFIX(calloc)(size_t, size_t);		///< The standard function.
extern void     PREFIX(free)(void *);					///< The standard function.


#ifdef __cplusplus
}
#endif


/** @} */