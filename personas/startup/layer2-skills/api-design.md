---
name: api-design
description: Designs clean, versioned REST or tRPC APIs that are easy to consume by the frontend and easy to extend without breaking changes
---

# API Design Skill

## Internal vs External APIs

### Internal (frontend ↔ backend)
**Default: tRPC**
- End-to-end type safety — no manual type syncing
- Zero boilerplate — no REST route files, no OpenAPI spec for internal use
- Auto-complete in the frontend
- Refactor-safe

```typescript
// server/routers/user.ts
export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ input }) => {
      return db.user.findUniqueOrThrow({ where: { id: input.id } })
    }),
})
```

### External (partner integrations, public API)
**Use REST + OpenAPI**
- Version at `/v1/` from day one — do this before you have a single partner, not after
- Never version for internal use — just update tRPC
- Document with Scalar / Swagger UI using openapi.yaml

## REST Conventions (for external APIs)

### Resource naming
```
GET    /v1/users          → list
GET    /v1/users/:id      → get one
POST   /v1/users          → create
PATCH  /v1/users/:id      → partial update
DELETE /v1/users/:id      → delete
```

### Response envelope (always)
```typescript
// Success
{ "data": { ... }, "meta": { "cursor": "...", "total": 100 } }

// Error
{ "error": { "code": "NOT_FOUND", "message": "User not found", "details": {} } }
```

### Error codes (be consistent)
| HTTP | code string | when |
|---|---|---|
| 400 | VALIDATION_ERROR | invalid input |
| 401 | UNAUTHORIZED | missing/invalid auth |
| 403 | FORBIDDEN | authenticated but not allowed |
| 404 | NOT_FOUND | resource doesn't exist |
| 409 | CONFLICT | duplicate, already exists |
| 422 | UNPROCESSABLE | valid format but business rule violation |
| 429 | RATE_LIMITED | too many requests |
| 500 | INTERNAL_ERROR | something broke on our side |

### Pagination (add from day one)
```typescript
// Cursor-based pagination — scales better than offset
{
  data: [...],
  meta: {
    cursor: "eyJpZCI6MTAwfQ==",  // base64 encoded last item ID
    hasMore: true
  }
}
```

## Before Shipping Any New Endpoint
- [ ] Validation on all inputs (Zod schema)
- [ ] Auth middleware applied
- [ ] Error responses follow the envelope format
- [ ] Rate limiting configured (or inherit from global middleware)
- [ ] Added to `openapi.yaml` (external) or tRPC router (internal)
- [ ] Tested with curl or Bruno before marking done
