from fastapi import APIRouter

from starterapp.clients.endpoints import router as client_router

router = APIRouter(prefix="/v1")

# /clients
router.include_router(client_router)
