from fastapi import APIRouter

from faskplusai.user.endpoints import router as user_router
from faskplusai.auth.endpoints import router as auth_router

router = APIRouter(prefix="/v1")

# /auth
router.include_router(auth_router)
# /user
router.include_router(user_router)
