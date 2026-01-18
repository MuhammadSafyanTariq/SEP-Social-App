# Story Feature - Implementation Architecture

## 📐 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Story      │  │   Story      │  │   Story      │         │
│  │   List       │  │   Create     │  │   View       │         │
│  │   Widget     │  │   Screen     │  │   Screen     │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
└─────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │
          │                 │                 │
┌─────────▼─────────────────▼─────────────────▼──────────────────┐
│                    STATE MANAGEMENT LAYER                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    ┌──────────────────┐                        │
│                    │  StoryController │                        │
│                    │    (GetX)        │                        │
│                    │                  │                        │
│                    │ • storyGroups    │                        │
│                    │ • myStories      │                        │
│                    │ • isLoading      │                        │
│                    │ • fetchStories() │                        │
│                    │ • viewStory()    │                        │
│                    │ • toggleLike()   │                        │
│                    └────────┬─────────┘                        │
│                             │                                   │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                              │
┌─────────────────────────────▼───────────────────────────────────┐
│                      BUSINESS LOGIC LAYER                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    ┌──────────────────┐                        │
│                    │   StoryService   │                        │
│                    │                  │                        │
│                    │ • createImage    │                        │
│                    │ • createVideo    │                        │
│                    │ • createAudio    │                        │
│                    │ • getAllStories  │                        │
│                    │ • toggleLike     │                        │
│                    │ • viewStory      │                        │
│                    └────────┬─────────┘                        │
│                             │                                   │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                              │
┌─────────────────────────────▼───────────────────────────────────┐
│                       DATA ACCESS LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                  ┌────────────────────┐                        │
│                  │  StoryRepository   │                        │
│                  │                    │                        │
│                  │ • createStory()    │                        │
│                  │ • getAllStories()  │                        │
│                  │ • getUserStories() │                        │
│                  │ • viewStory()      │                        │
│                  │ • likeStory()      │                        │
│                  │ • deleteStory()    │                        │
│                  └──────────┬─────────┘                        │
│                             │                                   │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                              │
┌─────────────────────────────▼───────────────────────────────────┐
│                        NETWORK LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│         ┌─────────────┐              ┌──────────────┐          │
│         │  IApiMethod │              │    Urls      │          │
│         │             │              │              │          │
│         │ • get()     │              │ • createStory│          │
│         │ • post()    │              │ • getAllStories│        │
│         │ • delete()  │              │ • viewStory  │          │
│         └──────┬──────┘              └──────────────┘          │
│                │                                                │
└────────────────┼────────────────────────────────────────────────┘
                 │
                 │ HTTP/HTTPS
                 │
┌────────────────▼────────────────────────────────────────────────┐
│                         BACKEND API                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  POST   /api/story/create          - Create story              │
│  GET    /api/story/all             - Get all stories           │
│  GET    /api/story/user/:userId    - Get user stories          │
│  GET    /api/story/:id             - Get story details         │
│  POST   /api/story/:id/view        - Mark as viewed            │
│  POST   /api/story/:id/like        - Like/unlike story         │
│  DELETE /api/story/:id             - Delete story              │
│  GET    /api/story/my-stories      - Get my stories            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Diagrams

### Creating a Story

```
User Action → Create Screen → File Selection
                    ↓
              Upload File (CreatePostCtrl)
                    ↓
              Get File URL
                    ↓
          StoryService.createImageStory()
                    ↓
          StoryRepository.createStory()
                    ↓
              POST /api/story/create
                    ↓
              Backend Creates Story
                    ↓
              Return Story Object
                    ↓
          Update StoryController
                    ↓
          Refresh UI → Show Success
```

### Viewing Stories

```
User Taps Story Avatar → Navigate to StoryViewScreen
                              ↓
                    Load Story Group
                              ↓
                    Display First Story
                              ↓
                StoryController.viewStory()
                              ↓
                StoryRepository.viewStory()
                              ↓
                POST /api/story/:id/view
                              ↓
                Backend Increments View Count
                              ↓
                Update Local State
                              ↓
                Show Updated View Count
```

### Liking a Story

```
User Taps Heart Icon → StoryController.toggleLike()
                              ↓
                    StoryRepository.likeStory()
                              ↓
                    POST /api/story/:id/like
                              ↓
                Backend Toggles Like (Add/Remove)
                              ↓
                Return { isLiked, likeCount }
                              ↓
                Update Local State
                              ↓
                Animate Heart Icon
                              ↓
                Show Updated Like Count
```

---

## 📦 Component Breakdown

### Story Model
```
Story
├── id: String
├── userId: String
├── type: 'story' | 'video'
├── files: List<StoryFile>
│   └── StoryFile
│       ├── file: String (URL)
│       ├── type: 'image' | 'video' | 'audio'
│       └── thumbnail: String?
├── caption: String
├── likes: List<String>
├── views: List<StoryView>
├── viewCount: int
├── likeCount: int
├── hasViewed: bool
├── isLiked: bool
├── expiresAt: DateTime
└── createdAt: DateTime
```

### UserStoryGroup
```
UserStoryGroup
├── user: UserData
│   ├── id: String
│   ├── name: String
│   ├── image: String
│   └── username: String
└── stories: List<Story>
    ├── hasUnviewedStories: bool
    └── latestStory: Story?
```

---

## 🎯 Feature Matrix

| Feature | Old (Bypass) | New (Backend) |
|---------|-------------|---------------|
| Image Stories | ✅ (as posts) | ✅ (dedicated) |
| Video Stories | ❌ | ✅ |
| Audio Stories | ❌ | ✅ |
| Captions | ✅ | ✅ |
| Likes | ✅ (post likes) | ✅ (story likes) |
| View Count | ❌ | ✅ |
| View Tracking | ❌ | ✅ (deduplicated) |
| 24h Expiration | ✅ (client-side) | ✅ (server-side) |
| Pagination | ❌ | ✅ |
| Multiple Media | ❌ | ✅ (planned) |
| Story Replies | ❌ | 🔄 (future) |

---

## 🔐 Security & Validation

### Client-Side
- File size validation
- File type validation
- Caption length limit (100 chars)
- Network error handling
- Token validation

### Server-Side
- JWT authentication required
- User authorization checks
- File type validation
- Story ownership validation
- Rate limiting
- Duplicate view prevention

---

## ⚡ Performance Optimizations

### Implemented
- ✅ Pagination for story lists
- ✅ Lazy loading of media
- ✅ Image caching (CachedNetworkImage)
- ✅ Video player optimization
- ✅ Local state management
- ✅ Expired story filtering

### Recommended
- 🔄 CDN for media files
- 🔄 Thumbnail generation
- 🔄 Video compression
- 🔄 Image optimization
- 🔄 Background prefetching
- 🔄 Offline caching

---

## 📈 Scalability Considerations

### Current Implementation
- Handles 20 stories per page
- Supports multiple concurrent users
- Real-time updates via polling
- Server-side expiration

### Future Improvements
- WebSocket for real-time updates
- Redis caching for view counts
- S3/CloudFront for media storage
- Database indexing optimization
- Background jobs for cleanup

---

## 🧪 Testing Strategy

### Unit Tests
- [ ] Story model serialization
- [ ] Repository methods
- [ ] Service layer logic
- [ ] Controller state management

### Integration Tests
- [ ] API endpoint calls
- [ ] File upload flow
- [ ] View tracking
- [ ] Like/unlike flow

### UI Tests
- [ ] Story creation flow
- [ ] Story viewing flow
- [ ] Navigation tests
- [ ] Error handling

### E2E Tests
- [ ] Complete user journey
- [ ] Multi-user scenarios
- [ ] Network failure scenarios
- [ ] Performance tests

---

## 📊 Monitoring & Analytics

### Metrics to Track
- Story creation rate
- Story view rate
- Like conversion rate
- Video vs image ratio
- Average story duration
- API response times
- Error rates
- User engagement

### Logging
- All API calls logged via `AppUtils.log()`
- Error tracking with stack traces
- User actions tracked
- Performance metrics

---

## 🔄 Migration Path

### Phase 1: Parallel Run (Week 1)
- Deploy new code
- Keep old implementation active
- Monitor errors
- Collect feedback

### Phase 2: Gradual Rollout (Week 2-3)
- Enable for 10% of users
- Monitor metrics
- Fix issues
- Increase to 50%

### Phase 3: Full Migration (Week 4)
- Enable for all users
- Deprecate old code
- Clean up unused files
- Update documentation

### Phase 4: Optimization (Ongoing)
- Performance tuning
- Feature additions
- Bug fixes
- User feedback integration

---

**Documentation Version:** 1.0.0
**Last Updated:** January 16, 2026
