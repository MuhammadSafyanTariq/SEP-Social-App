# Backend Story Route Bug - Priority Issue

## Problem Summary
The `/api/story/all` endpoint returns **400 Bad Request** with error: `"Cast to ObjectId failed for value 'all' (type string) at path '_id'"`

## Root Cause
Express route priority issue - the dynamic route `/api/story/:storyId` is matching before the static route `/api/story/all`, treating "all" as a story ID.

## Current Behavior
```
GET /api/story/all?page=1&limit=20
❌ Response: 400 Bad Request
Error: "Cast to ObjectId failed for value 'all'"

GET /api/stories
❌ Response: 200 OK (but returns HTML admin panel instead of JSON)
```

## Expected Behavior
```
GET /api/story/all?page=1&limit=20
✅ Response: 200 OK
{
  "status": true,
  "code": 200,
  "message": "Stories retrieved successfully",
  "data": {
    "stories": [...],
    "pagination": {...}
  }
}
```

## Required Fix
**Reorder routes in your Express router** - static routes MUST be defined BEFORE dynamic routes:

```javascript
// ✅ CORRECT ORDER
router.get('/api/story/all', getAllStoriesHandler);          // Static first
router.get('/api/story/my-stories', getMyStoriesHandler);    // Static
router.get('/api/story/user/:userId', getUserStoriesHandler); // Dynamic
router.get('/api/story/:storyId', getStoryByIdHandler);      // Dynamic last
router.get('/api/story/:storyId/view', viewStoryHandler);    // More specific dynamic
router.get('/api/story/:storyId/like', likeStoryHandler);    // More specific dynamic

// ❌ CURRENT (WRONG) ORDER
router.get('/api/story/:storyId', getStoryByIdHandler);      // Dynamic first (catches everything!)
router.get('/api/story/all', getAllStoriesHandler);          // Never reached
```

## Alternative Solutions
If reordering is not possible:
1. Create new endpoint: `GET /api/stories/all` or `GET /api/stories/list`
2. Use query parameter: `GET /api/story?action=all`

## Testing After Fix
```bash
curl -X GET "http://67.225.241.58:4004/api/story/all?page=1&limit=20" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Expected: JSON response with stories array, not 400 error.

## Priority
🔴 **HIGH** - Blocking story feature deployment. Currently using `/api/story/my-stories` as temporary workaround (only shows current user's stories, not all users).

## Contact
Flutter Team - Story Feature Integration
Date: January 18, 2026
